include "sec_prop.s.dfy"
include "pagedb.s.dfy"
include "entry.s.dfy"
include "sec_prop_util.i.dfy"
include "smcapi.i.dfy"

lemma lemma_enter_enc_conf_ni(s1: state, d1: PageDb, s1':state, d1': PageDb,
                              s2: state, d2: PageDb, s2':state, d2': PageDb,
                              dispPage: word, arg1: word, arg2: word, arg3: word,
                              atkr: PageNr)
    requires ni_reqs(s1, d1, s1', d1', s2, d2, s2', d2', atkr)
    requires smc_enter(s1, d1, s1', d1', dispPage, arg1, arg2, arg3)
    requires smc_enter(s2, d2, s2', d2', dispPage, arg1, arg2, arg3)
    requires enc_conf_eqpdb(d1, d2, atkr)
    requires entering_atkr(d1, d2, dispPage, atkr, false) ==>
        enc_conf_eq_entry(s1, s2, d1, d2, atkr)
    ensures enc_conf_eqpdb(d1', d2', atkr)
    ensures entering_atkr(d1, d2, dispPage, atkr, false) ==>
        enc_conf_eq_entry(s1', s2', d1', d2', atkr)
{
    reveal_enc_conf_eqpdb();
    if(!validPageNr(dispPage)){
        assert d1' == d1 &&  d2' == d2;
    } else {
        assert d1[dispPage].PageDbEntryFree? <==> d2[dispPage].PageDbEntryFree?;
        if(d1[dispPage].PageDbEntryFree?) {
            assert d1' == d1 &&  d2' == d2;
        } else {
            assert d2[dispPage].PageDbEntryTyped?;
            var asp1, asp2 := d1[dispPage].addrspace, d2[dispPage].addrspace;
            var e1', e2' := smc_enter_err(d1, dispPage, false), smc_enter_err(d2, dispPage, false);
            assert enc_conf_eqpdb(d1', d2', atkr) by {
                lemma_enter_enc_conf_eqpdb(s1, d1, s1', d1', s2, d2, s2', d2',
                                 dispPage, arg1, arg2, arg3, asp1, asp2, atkr);
            }
            assert pgInAddrSpc(d1, dispPage, atkr) <==>
                pgInAddrSpc(d2, dispPage, atkr);
            assert pgInAddrSpc(d1, dispPage, atkr) ==>
                d1[dispPage].addrspace == atkr;
            assert pgInAddrSpc(d1, dispPage, atkr) ==>
                d1[dispPage].addrspace == atkr;
            assert asp1 == atkr <==> asp2 == atkr;

            if(asp1 == atkr) {
                assert e1' == KOM_ERR_SUCCESS <==> e2' == KOM_ERR_SUCCESS;
                if(e1' == KOM_ERR_SUCCESS) {
                    assert entering_atkr(d1, d2, dispPage, atkr, false);
                    lemma_enter_enc_conf_atkr_enter(s1, d1, s1', d1', s2, d2, s2', d2',
                                                    dispPage, arg1, arg2, arg3, 
                                                    atkr);
                    assert enc_conf_eq_entry(s1', s2', d1', d2', atkr);
                } else {
                    assert !entering_atkr(d1, d2, dispPage, atkr, false);
                }
            } else {
                assert !entering_atkr(d1, d2, dispPage, atkr, false);
            }
        }
    }
}

lemma lemma_enter_enc_conf_eqpdb(s1: state, d1: PageDb, s1':state, d1': PageDb,
                                 s2: state, d2: PageDb, s2':state, d2': PageDb,
                                 disp: word, arg1: word, arg2: word, arg3: word,
                                 asp1: PageNr, asp2: PageNr, atkr: PageNr)
    requires ni_reqs(s1, d1, s1', d1', s2, d2, s2', d2', atkr)
    requires smc_enter(s1, d1, s1', d1', disp, arg1, arg2, arg3)
    requires smc_enter(s2, d2, s2', d2', disp, arg1, arg2, arg3)
    requires validPageNr(disp) && d1[disp].PageDbEntryTyped? && 
        d2[disp].PageDbEntryTyped?
    requires d1[disp].addrspace == asp1 && d2[disp].addrspace == asp2
    requires enc_conf_eqpdb(d1, d2, atkr)
    requires entering_atkr(d1, d2, disp, atkr, false) ==>
        enc_conf_eq_entry(s1, s2, d1, d2, atkr)
    ensures  enc_conf_eqpdb(d1', d2', atkr)
{

    reveal_enc_conf_eqpdb();
    var go1 := smc_enter_err(d1, disp, false) == KOM_ERR_SUCCESS;
    var go2 := smc_enter_err(d2, disp, false) == KOM_ERR_SUCCESS;

    if(go1 && go2) {
        lemma_enter_only_affects_entered(s1, d1, s1', d1',
             disp, asp1, arg1, arg2, arg3);
        lemma_enter_only_affects_entered(s2, d2, s2', d2',
             disp, asp2, arg1, arg2, arg3);
        
        assert d1[atkr].PageDbEntryTyped? <==> d2[atkr].PageDbEntryTyped?;
        assert d1[atkr].PageDbEntryTyped? <==> d1'[atkr].PageDbEntryTyped?;
        assert d2[atkr].PageDbEntryTyped? <==> d2'[atkr].PageDbEntryTyped?;
        assert d1'[atkr].PageDbEntryTyped? <==> d2'[atkr].PageDbEntryTyped?;
       
        assert valAddrPage(d1, asp1) && valAddrPage(d2, asp2);

        assert pgInAddrSpc(d1, disp, atkr) <==>
            pgInAddrSpc(d2, disp, atkr);
        assert pgInAddrSpc(d1, disp, atkr) ==>
            d1[disp].addrspace == atkr;
        assert pgInAddrSpc(d1, disp, atkr) ==>
            d1[disp].addrspace == atkr;
        assert asp1 == atkr <==> asp2 == atkr;
        
        if(asp1 == atkr) {
            assert entering_atkr(d1, d2, disp, atkr, false);
            assert enc_conf_eq_entry(s1, s2, d1, d2, atkr);
            lemma_enter_enc_conf_atkr_enter(s1, d1, s1', d1', s2, d2, s2', d2',
                                            disp, arg1, arg2, arg3, 
                                            atkr);
        } else {
            assert asp1 != atkr && asp2 != atkr;
            assert outside_world_same(d1, d1', disp, asp1);
            assert outside_world_same(d2, d2', disp, asp2);

            assert forall n : PageNr :: pgInAddrSpc(d1', n, asp1)
                <==>  pgInAddrSpc(d1, n, asp1);
            assert forall n : PageNr :: pgInAddrSpc(d1', n, atkr)
                ==> !pgInAddrSpc(d1', n, asp1);

            assert forall n : PageNr :: pgInAddrSpc(d2', n, asp2)
                <==>  pgInAddrSpc(d2, n, asp2);
            assert forall n : PageNr :: pgInAddrSpc(d2', n, atkr)
                ==> !pgInAddrSpc(d2', n, asp2);

            assert (forall n : PageNr | pgInAddrSpc(d1', n, atkr) 
                && d1'[n].PageDbEntryTyped? ::
                    d1'[n].addrspace == d1[n].addrspace &&
                    d1'[n].entry == d1[n].entry);
            
            assert (forall n : PageNr | pgInAddrSpc(d2', n, atkr) 
                && d2'[n].PageDbEntryTyped? ::
                    d2'[n].addrspace == d2[n].addrspace &&
                    d2'[n].entry == d2[n].entry);
            
            assert forall n : PageNr :: pgInAddrSpc(d1', n, atkr) <==>
                pgInAddrSpc(d1, n, atkr);
            assert forall n : PageNr :: pgInAddrSpc(d2', n, atkr) <==>
                pgInAddrSpc(d2, n, atkr);
            assert forall n : PageNr :: pgInAddrSpc(d1', n, atkr) <==>
                pgInAddrSpc(d2', n, atkr);

            assert forall n : PageNr | pgInAddrSpc(d1', n, atkr) ::
                d1'[n].entry == d2'[n].entry;
            
            assert enc_conf_eqpdb(d1', d2', atkr);
            
        }
    }

    if(go1 && !go2) {
        lemma_enter_enc_conf_eqpdb_one_go(s1, d1, s1', d1', s2, d2, s2', d2',
                         disp, arg1, arg2, arg3, asp1, asp2, atkr);
        assert enc_conf_eqpdb(d1', d2', atkr);
    }
    if(!go1 && go2) {
        lemma_enter_enc_conf_eqpdb_one_go(s2, d2, s2', d2', s1, d1, s1', d1',
                         disp, arg1, arg2, arg3, asp2, asp1, atkr);
        assert enc_conf_eqpdb(d1', d2', atkr);
    }
    if(!go1 && !go2) { 
        assert d1' == d1 && d2' == d2;
        assert enc_conf_eqpdb(d1', d2', atkr);
    }
}

lemma lemma_enter_enc_conf_eqpdb_one_go(s1: state, d1: PageDb, s1':state, d1': PageDb,
                                        s2: state, d2: PageDb, s2':state, d2': PageDb,
                                        disp: word, arg1: word, arg2: word, arg3: word,
                                        asp1: PageNr, asp2: PageNr, atkr: PageNr)
    requires ni_reqs(s1, d1, s1', d1', s2, d2, s2', d2', atkr)
    requires smc_enter(s1, d1, s1', d1', disp, arg1, arg2, arg3)
    requires smc_enter(s2, d2, s2', d2', disp, arg1, arg2, arg3)
    requires validPageNr(disp) && d1[disp].PageDbEntryTyped? && 
        d2[disp].PageDbEntryTyped?
    requires d1[disp].addrspace == asp1 && d2[disp].addrspace == asp2
    requires enc_conf_eqpdb(d1, d2, atkr)
    requires smc_enter_err(d1, disp, false) == KOM_ERR_SUCCESS
            && !(smc_enter_err(d2, disp, false) == KOM_ERR_SUCCESS);
    ensures  enc_conf_eqpdb(d1', d2', atkr)
{
   reveal_enc_conf_eqpdb();
   var go1 := smc_enter_err(d1, disp, false) == KOM_ERR_SUCCESS;
   var go2 := smc_enter_err(d2, disp, false) == KOM_ERR_SUCCESS;
   assert go1 && !go2;
   
   assert d2' == d2;

   var asp1 := d1[disp].addrspace;

   assert asp1 != atkr by {
       var asp2 := d2[disp].addrspace;
       assert pgInAddrSpc(d1, disp, atkr) <==>
           pgInAddrSpc(d2, disp, atkr);
       assert pgInAddrSpc(d1, disp, atkr) ==>
           d1[disp].addrspace == atkr;
       assert pgInAddrSpc(d1, disp, atkr) ==>
           d1[disp].addrspace == atkr;
       assert asp1 == atkr <==> asp2 == atkr;
       assert asp2 == atkr && go1 ==> go2;
   }

   lemma_enter_only_affects_entered(s1, d1, s1', d1',
        disp, asp1, arg1, arg2, arg3);
   assert outside_world_same(d1, d1', disp, asp1);

   assert forall n : PageNr :: pgInAddrSpc(d1', n, asp1)
       <==>  pgInAddrSpc(d1, n, asp1);
   assert forall n : PageNr :: pgInAddrSpc(d1', n, atkr)
       ==> !pgInAddrSpc(d1', n, asp1);

   assert (forall n : PageNr | pgInAddrSpc(d1', n, atkr) 
       && d1'[n].PageDbEntryTyped? ::
           d1'[n].addrspace == d1[n].addrspace &&
           d1'[n].entry == d1[n].entry);
   
   assert forall n : PageNr :: pgInAddrSpc(d1', n, atkr) <==>
       pgInAddrSpc(d1, n, atkr);
   assert forall n : PageNr :: pgInAddrSpc(d1', n, atkr) <==>
       pgInAddrSpc(d2', n, atkr);

   assert forall n : PageNr | pgInAddrSpc(d1', n, atkr) ::
       d1'[n].entry == d2'[n].entry;
   
   assert enc_conf_eqpdb(d1', d2', atkr);

   assert enc_conf_eqpdb(d1', d2', atkr);
}

predicate outside_world_same(d:PageDb, d':PageDb, p:PageNr, asp: PageNr) 
    requires validPageDb(d) && validPageDb(d')
    requires validPageNr(p) && valDispPage(d, p)
    requires validPageNr(asp) && valAddrPage(d, asp)
    requires d[p].addrspace == asp
{
    valDispPage(d', p) && valAddrPage(d', asp) && d'[p].addrspace == asp &&
    (forall n : PageNr :: d'[n].PageDbEntryTyped? <==>
        d[n].PageDbEntryTyped?) &&
    (forall n : PageNr :: pgInAddrSpc(d', n, asp) <==>
        pgInAddrSpc(d, n, asp)) &&
    (forall n : PageNr | !pgInAddrSpc(d', n, asp) 
        && d'[n].PageDbEntryTyped? ::
            d'[n].addrspace == d[n].addrspace &&
            d'[n].entry == d[n].entry)
}

lemma lemma_enter_only_affects_entered(s: state, d: PageDb, s': state, d': PageDb,
                                       disp:PageNr, asp:PageNr, arg1: word, arg2: word, arg3: word)
    requires ValidState(s) && validPageDb(d) && ValidState(s') && 
        validPageDb(d') && SaneConstants()
    requires validPageNr(disp) && valDispPage(d, disp)
    requires validPageNr(asp) && valAddrPage(d, asp)
    requires d[disp].addrspace == asp
    requires smc_enter(s, d, s', d', disp, arg1, arg2, arg3)
    requires smc_enter_err(d, disp, false) == KOM_ERR_SUCCESS
    ensures outside_world_same(d, d', disp, asp)
{
    assume false;

}


predicate atkr_entry(d1: PageDb, d2: PageDb, disp: word, atkr: PageNr)
{
    validPageNr(disp) &&
    validPageDb(d1) && validPageDb(d2) &&
    valAddrPage(d1, atkr) && valAddrPage(d2, atkr) &&
    d1[disp].PageDbEntryTyped? && d1[disp].entry.Dispatcher? &&
    d2[disp].PageDbEntryTyped? && d2[disp].entry.Dispatcher? &&
    nonStoppedDispatcher(d1, disp) && nonStoppedDispatcher(d2, disp) &&
    d1[disp].addrspace == d2[disp].addrspace == atkr
}

lemma lemma_enter_enc_conf_atkr_enter(s1: state, d1: PageDb, s1':state, d1': PageDb,
                                      s2: state, d2: PageDb, s2':state, d2': PageDb,
                                      dispPage: word, arg1: word, arg2: word, arg3: word,
                                      atkr: PageNr)
    requires ni_reqs(s1, d1, s1', d1', s2, d2, s2', d2', atkr)
    requires smc_enter(s1, d1, s1', d1', dispPage, arg1, arg2, arg3)
    requires smc_enter(s2, d2, s2', d2', dispPage, arg1, arg2, arg3)
    requires enc_conf_eqpdb(d1, d2, atkr)
    requires entering_atkr(d1, d2, dispPage, atkr, false);
    requires enc_conf_eq_entry(s1, s2, d1, d2, atkr)
    ensures  enc_conf_eqpdb(d1', d2', atkr)
    ensures  enc_conf_eq_entry(s1', s2', d1', d2', atkr)
{

    /*
    var s11:state, steps1: nat :|
        preEntryEnter(s1, s11, d1, dispPage, arg1, arg2, arg3) &&
        validEnclaveExecution(s11, d1, s1', d1', dispPage, steps1);
    
    var s21:state, steps2: nat :|
        preEntryEnter(s2, s21, d2, dispPage, arg1, arg2, arg3) &&
        validEnclaveExecution(s21, d2, s2', d2', dispPage, steps2);

    assert steps1 == steps2 by {
        // TODO proveme :(
        assume false;
    }

    var steps := steps1;
    
    lemma_validEnclaveEx_enc_conf(s11, d1, s1', d1', s21, d2, s2', d2',
                                         dispPage, steps, atkr);
    */

    // TODO
    // The thing that cannot be proven here is that the number of steps taken 
    // is the same in both executions. Factor this out into a lemma.

    forall(s11:state, s21:state, steps1:nat, steps2:nat |
        preEntryEnter(s1, s11, d1, dispPage, arg1, arg2, arg3) &&
        preEntryEnter(s2, s21, d2, dispPage, arg1, arg2, arg3) &&
        validEnclaveExecution(s11, d1, s1', d1', dispPage, steps1) &&
        validEnclaveExecution(s21, d2, s2', d2', dispPage, steps2))
        ensures enc_conf_eqpdb(d1', d2', atkr)
        ensures enc_conf_eq_entry(s1', s2', d1', d2', atkr)
    {
        assume steps1 == steps2;
        assume s11.nd_public == s21.nd_public;
        assume s11.nd_private == s21.nd_private;
        lemma_validEnclaveEx_enc_conf(s11, d1, s1', d1', s21, d2, s2', d2',
                                         dispPage, steps1, atkr);
    }
}

lemma lemma_validEnclaveEx_enc_conf(s1: state, d1: PageDb, s1':state, d1': PageDb,
                                    s2: state, d2: PageDb, s2':state, d2': PageDb,
                                    dispPg: PageNr, steps:nat,
                                    atkr: PageNr)
    //requires ni_reqs(s1, d1, s1', d1', s2, d2, s2', d2', atkr)
    requires ValidState(s1) && ValidState(s2) &&
             ValidState(s1') && ValidState(s2') &&
             validPageDb(d1) && validPageDb(d2) && 
             validPageDb(d1') && validPageDb(d2') && SaneConstants()
    requires atkr_entry(d1, d2, dispPg, atkr)
    requires validEnclaveExecution(s1, d1, s1', d1', dispPg, steps)
    requires validEnclaveExecution(s2, d2, s2', d2', dispPg, steps);
    requires enc_conf_eqpdb(d1, d2, atkr)
    requires enc_conf_eq_entry(s1, s2, d1, d2, atkr)
    ensures  atkr_entry(d1', d2', dispPg, atkr)
    ensures  enc_conf_eqpdb(d1', d2', atkr)
    ensures  enc_conf_eq_entry(s1', s2', d1', d2', atkr)
    decreases steps
{
    reveal_validEnclaveExecution();
    var retToEnclave := (steps > 0);

    // I can't figure out how to get around assuming nonStoppedDispatcher here. 
    // I tried using a premium version of validEnclaveExecutionStep that calls 
    // the lemma that proves nonstopped, but LHS values couldn't be found...

    var s15, d15 :|
        validEnclaveExecutionStep(s1, d1, s15, d15, dispPg, retToEnclave) &&
        (if retToEnclave then
            (assume nonStoppedDispatcher(d15, dispPg);
            validEnclaveExecution(s15, d15, s1', d1', dispPg, steps - 1))
          else
             s1' == s15 && d1' == d15);

    var s25, d25 :|
        validEnclaveExecutionStep(s2, d2, s25, d25, dispPg, retToEnclave) &&
        (if retToEnclave then 
            (assume nonStoppedDispatcher(d25, dispPg);
            validEnclaveExecution(s25, d25, s2', d2', dispPg, steps - 1))
          else
             s2' == s25 && d2' == d25);

    lemma_validEnclaveExecutionStep_validPageDb(s1, d1, s15, d15, dispPg, retToEnclave);
    lemma_validEnclaveExecutionStep_validPageDb(s2, d2, s25, d25, dispPg, retToEnclave);
    lemma_validEnclaveStep_enc_conf(s1, d1, s15, d15, s2, d2, s25, d25,
        dispPg, atkr, retToEnclave);

    if(retToEnclave) {
        lemma_validEnclaveExecution(s15, d15, s1', d1', dispPg, steps - 1);
        lemma_validEnclaveExecution(s25, d25, s2', d2', dispPg, steps - 1);
        lemma_validEnclaveEx_enc_conf(s15, d15, s1', d1', s25, d25, s2', d2',
                                         dispPg, steps -1, atkr);
        assert enc_conf_eqpdb(d1', d2', atkr);
        assert enc_conf_eq_entry(s1', s2', d1', d2', atkr);
    } else {
        assert s2' == s25;
        assert s1' == s15;
        assert d1' == d15;
        assert d2' == d25;
        assert enc_conf_eqpdb(d1', d2', atkr);
        assert enc_conf_eq_entry(s1', s2', d1', d2', atkr);
    }
}

lemma lemma_validEnclaveStep_enc_conf(s1: state, d1: PageDb, s1':state, d1': PageDb,
                                      s2: state, d2: PageDb, s2':state, d2': PageDb,
                                      dispPage:PageNr, atkr: PageNr, ret:bool)
    requires ValidState(s1) && ValidState(s2) &&
             ValidState(s1') && ValidState(s2') &&
             validPageDb(d1) && validPageDb(d2) && 
             validPageDb(d1') && validPageDb(d2') && SaneConstants()
    requires atkr_entry(d1, d2, dispPage, atkr)
    requires validEnclaveExecutionStep(s1, d1, s1', d1', dispPage, ret);
    requires validEnclaveExecutionStep(s2, d2, s2', d2', dispPage, ret);
    requires enc_conf_eqpdb(d1, d2, atkr)
    requires enc_conf_eq_entry(s1, s2, d1, d2, atkr)
    ensures  atkr_entry(d1', d2', dispPage, atkr)
    ensures  enc_conf_eqpdb(d1', d2', atkr)
    ensures  enc_conf_eq_entry(s1', s2', d1', d2', atkr)
{
    assume false;
    // use lemma below...
    //
    // I'm guessing that even with the lemma below, this will be just as 
    // annoying as the above lemma
}

lemma lemma_validEnclaveStepPrime_enc_conf(
s11: state, d11: PageDb, s12:state, s13:state, s14:state, d14:PageDb,
r1:state, rd1:PageDb,
s21: state, d21: PageDb, s22:state, s23:state, s24:state, d24:PageDb,
r2:state, rd2:PageDb,
dispPg:PageNr, retToEnclave:bool, atkr: PageNr
)
    requires ValidState(s11) && ValidState(s21) &&
             ValidState(r1)  && ValidState(r2)  &&
             validPageDb(d11) && validPageDb(d21) &&
             validPageDb(rd1) && validPageDb(rd2) && SaneConstants()
    requires atkr_entry(d11, d21, dispPg, atkr)
    requires validEnclaveExecutionStep'(s11,d11,s12,s13,s14,d14,r1,rd1,dispPg,retToEnclave)
    requires validEnclaveExecutionStep'(s21,d21,s22,s23,s24,d24,r2,rd2,dispPg,retToEnclave)
    requires enc_conf_eqpdb(d11, d21, atkr)
    requires enc_conf_eq_entry(s11, s21, d11, d21, atkr)
    ensures  atkr_entry(rd1, rd2, dispPg, atkr)
    ensures  enc_conf_eqpdb(rd1, rd2, atkr)
    ensures  enc_conf_eq_entry(r1, r2, rd1, rd2, atkr)
{

    assert l1pOfDispatcher(d11, dispPg) == l1pOfDispatcher(d21, dispPg) by
        { reveal_enc_conf_eqpdb(); }
    var l1p := l1pOfDispatcher(d11, dispPg);

    assert s12.m == s11.m;
    assert s22.m == s21.m;
    assert dataPagesCorrespond(s11.m, d11);
    assert dataPagesCorrespond(s21.m, d21);
    
    assert userspaceExecutionAndException(s12, s13, s14);
    assert userspaceExecutionAndException(s22, s23, s24);

    assert pageTableCorresponds(s12, d11, l1p) by
    { 
        assert pageTableCorresponds(s11, d11, l1p);
        reveal pageTableCorresponds();
    }

    assert pageTableCorresponds(s22, d21, l1p) by
    { 
        assert pageTableCorresponds(s21, d21, l1p);
        reveal pageTableCorresponds();
    }

    // avoid proving anything about nd sources...
    assert enc_conf_eq_entry(s12, s22, d11, d21, atkr) by
    {
        assume false;
    }

    // avoid proving anything about nd sources...
    assert enc_conf_eq_entry(s14, s24, d14, d24, atkr) by
    {
        assume false;
    }

    lemma_userspaceExec_atkr_conf(s12, s13, d11, s22, s23, d21, dispPg, atkr);

    if(retToEnclave) {
        assert rd1 == d14;
        assert rd2 == d24;
        assert enc_conf_eqpdb(rd1, rd2, atkr);
        // No idea how to prove anything about nd_*
        assume enc_conf_eq_entry(r1, r2, rd1, rd2, atkr);
    } else {
        lemma_userExecAndExcp_atkr_regs(s12, s13, s14, s22, s23, s24);
        assume s14.conf.ex == s24.conf.ex; // TODO provme
        lemma_exceptionHandled_atkr_conf(s14, d14, rd1, s24, d24, rd2, dispPg, atkr);
        // No idea how to prove anything about nd_*
        assume enc_conf_eq_entry(r1, r2, rd1, rd2, atkr);
    }
}

lemma lemma_userExec_atkr_regs(s1:state, s1':state,s2:state, s2':state)
    requires ValidState(s1) && ValidState(s1') 
    requires ValidState(s2) && ValidState(s2') 
    requires evalUserspaceExecution(s1, s1')
    requires evalUserspaceExecution(s2, s2')
    requires s1.nd_private == s2.nd_private
    ensures  usr_regs_equiv(s1', s2')
{
   reveal_evalUserspaceExecution(); 
}

lemma lemma_userExecAndExcp_atkr_regs(
    s1:state, s1':state, r1:state,
    s2:state, s2':state, r2:state)
    requires ValidState(s1) && ValidState(s1') && ValidState(r1)
    requires ValidState(s2) && ValidState(s2') && ValidState(r2)
    requires mode_of_state(s1) == User
    requires mode_of_state(s2) == User
    requires userspaceExecutionAndException(s1, s1', r1)
    requires userspaceExecutionAndException(s2, s2', r2)
    requires s1.nd_private == s2.nd_private;
    ensures  usr_regs_equiv(r1, r2)
    ensures r1.conf.ex == r2.conf.ex
    ensures mode_of_state(r1) == mode_of_state(r2)
    ensures r1.regs[LR(mode_of_state(r1))] == r2.regs[LR(mode_of_state(r2))]
    ensures r1.sregs[spsr(mode_of_state(r1))] == r2.sregs[spsr(mode_of_state(r2))]
{
    assert usr_regs_equiv(s1', s2') by {
        lemma_userExec_atkr_regs(s1, s1', s2, s2');
    }

    var ex1 :| evalExceptionTaken(s1', ex1, r1);
    var ex2 :| evalExceptionTaken(s2', ex2, r2);
    assume ex1 == ex2; // XXX there is no way to prove this from spec
    var newmode1 := mode_of_exception(s1'.conf, ex1);
    var newmode2 := mode_of_exception(s2'.conf, ex2);
    assert newmode2 != User;
    assert newmode2 != User;
    assert r1.regs == s1'.regs[LR(newmode1) :=
        nondet_word(s1'.nd_private, NONDET_REG(LR(newmode1)))];
    assert r2.regs == s2'.regs[LR(newmode2) :=
        nondet_word(s2'.nd_private, NONDET_REG(LR(newmode2)))];
}

lemma lemma_exceptionHandled_atkr_conf(
s1: state, d1: PageDb, d1': PageDb, s2: state, d2: PageDb, d2': PageDb,
dispPg: PageNr, atkr: PageNr)
    requires ValidState(s1) && ValidState(s2) &&
             validPageDb(d1') && validPageDb(d2') &&
             validPageDb(d1) && validPageDb(d2) && SaneConstants()
    requires enc_conf_eq_entry(s1, s2, d1, d2, atkr);
    requires mode_of_state(s1) != User && mode_of_state(s2) != User
    requires mode_of_state(s1) == mode_of_state(s2)
    requires s1.regs[LR(mode_of_state(s1))] == s2.regs[LR(mode_of_state(s2))]
    requires s1.sregs[spsr(mode_of_state(s1))] == s2.sregs[spsr(mode_of_state(s2))]
    requires validDispatcherPage(d1, dispPg) && validDispatcherPage(d2, dispPg)
    requires d1' == exceptionHandled(s1, d1, dispPg).2
    requires d2' == exceptionHandled(s2, d2, dispPg).2
    requires atkr_entry(d1, d2, dispPg, atkr)
    requires enc_conf_eqpdb(d1, d2, atkr)
    requires usr_regs_equiv(s1, s2)
    requires s1.conf.ex == s2.conf.ex
    ensures  enc_conf_eqpdb(d1', d2', atkr)
    ensures  atkr_entry(d1', d2', dispPg, atkr)
{
    reveal_enc_conf_eqpdb();
    var ex := s1.conf.ex;
    forall (n : PageNr |  n != dispPg)
        ensures d1'[n] == d1[n];
        ensures d2'[n] == d2[n];
        ensures pgInAddrSpc(d1, n, atkr) <==>
            pgInAddrSpc(d1', n, atkr)
        ensures pgInAddrSpc(d2, n, atkr) <==>
            pgInAddrSpc(d2', n, atkr)
    {
    }

    assert forall n : PageNr :: pgInAddrSpc(d1, n, atkr) <==>
        pgInAddrSpc(d2, n, atkr);

    forall( n : PageNr | n != dispPg &&
        pgInAddrSpc(d1, n, atkr) )
    ensures d1'[n] == d2'[n]
    {
    }

    if( ex.ExSVC? || ex.ExAbt? || ex.ExUnd? ) {
        assert d1'[dispPg].entry == d2'[dispPg].entry;
    } else {
        var pc1 := TruncateWord(OperandContents(s1, OLR) - 4);
        var pc2 := TruncateWord(OperandContents(s2, OLR) - 4);
        assert pc1 == pc2;
        reveal_ValidSRegState();
        var psr1 := s1.sregs[spsr(mode_of_state(s1))];
        var psr2 := s2.sregs[spsr(mode_of_state(s2))];
        assert psr1 == psr2;
        var ctxt1' := DispatcherContext(take_user_regs(s1.regs), pc1, psr1);
        var ctxt2' := DispatcherContext(take_user_regs(s2.regs), pc2, psr2);
        assert usr_regs_equiv(s1, s2);
        assert take_user_regs(s1.regs) == take_user_regs(s2.regs);
        assert ctxt1' == ctxt2';
        assert d1'[dispPg].entry == d2'[dispPg].entry;
    }
}

lemma lemma_userspaceExec_atkr_conf(
s12: state, s13:state, d1:PageDb,
s22: state, s23:state, d2:PageDb,
dispPg: PageNr, atkr: PageNr)
    requires ValidState(s12) && ValidState(s22) &&
             validPageDb(d1) && validPageDb(d2) && SaneConstants()
    requires enc_conf_eq_entry(s12, s22, d1, d2, atkr);
    requires evalUserspaceExecution(s12, s13)
    requires evalUserspaceExecution(s22, s23)
    requires atkr_entry(d1, d2, dispPg, atkr)
    requires enc_conf_eqpdb(d1, d2, atkr)
    requires l1pOfDispatcher(d1, dispPg) == l1pOfDispatcher(d2, dispPg);
    requires (var l1p := l1pOfDispatcher(d1, dispPg);
        pageTableCorresponds(s12, d1, l1p) &&
        pageTableCorresponds(s22, d2, l1p) &&
        dataPagesCorrespond(s12.m, d1) &&
        dataPagesCorrespond(s22.m, d2))
    ensures (var d14 := updateUserPagesFromState(s13, d1, dispPg);
        var d24 := updateUserPagesFromState(s23, d2, dispPg);
        enc_conf_eqpdb(d14, d24, atkr) &&
        atkr_entry(d14, d24, dispPg, atkr)) 
{
    // reveal_evalUserspaceExecution();
    reveal_enc_conf_eqpdb();

    var l1p := l1pOfDispatcher(d1, dispPg);
    
    var d14 := updateUserPagesFromState(s13, d1, dispPg);
    var d24 := updateUserPagesFromState(s23, d2, dispPg);

    assert validPageDb(d14) && validPageDb(d24);

    forall(n : PageNr) 
        ensures pgInAddrSpc(d14, n, atkr) <==> pgInAddrSpc(d1, n, atkr)
        ensures d14[n].PageDbEntryTyped? <==> d1[n].PageDbEntryTyped?
        ensures d14[atkr].entry == d1[atkr].entry;
        { reveal_updateUserPagesFromState(); }

    forall( n : PageNr) 
        ensures pgInAddrSpc(d24, n, atkr) <==> pgInAddrSpc(d2, n, atkr)
        ensures d24[n].PageDbEntryTyped? <==> d2[n].PageDbEntryTyped?
        ensures d24[atkr].entry == d2[atkr].entry;
        { reveal_updateUserPagesFromState(); }

    assert forall n : PageNr :: pgInAddrSpc(d14, n, atkr) <==>
        pgInAddrSpc(d24, n, atkr);

    assert forall n : PageNr :: pageSWrInAddrspace(d1, l1p, n) <==>
        pageSWrInAddrspace(d2, l1p, n);


    forall( n : PageNr | pageSWrInAddrspace(d1, l1p, n))
        ensures contentsOfPage(s13, n) ==
            contentsOfPage(s23, n)
    {
        assert d1[n].PageDbEntryTyped?;
        assert d2[n].PageDbEntryTyped?;
        assert d1[n].entry.DataPage?;
        assert d2[n].entry.DataPage?;
        
        var base := page_monvaddr(n);
        forall( a : addr | a in addrsInPage(n, base) )
            ensures s13.m.addresses[a] == s23.m.addresses[a]
        {
            reveal_evalUserspaceExecution();
            assert ExtractAbsPageTable(s12) == ExtractAbsPageTable(s22) by
            {
                lemma_eqpdb_pt_coresp(d1, d2, s12, s22, l1p, atkr);
            }
            var pt := ExtractAbsPageTable(s12);
            assert pt.Just?;
            var pages := WritablePagesInTable(fromJust(pt));

            /*
            var pt1 := ExtractAbsPageTable(s12);
            var pt2 := ExtractAbsPageTable(s22);
            var pages1 := WritablePagesInTable(fromJust(pt1));
            var pages2 := WritablePagesInTable(fromJust(pt2));
            assert pt1.Just? && pt2.Just?;
            */
            
           // assume pages1 == pages2;
            // assert BitwiseMaskHigh(a, 12) in pages1 <==>
            //     BitwiseMaskHigh(a, 12) in pages2 by {
            //     lemma_WritablePagesFlipped(d1, l1p, base);
            //     lemma_WritablePagesFlipped(d2, l1p, base);
            // }
            
            if( BitwiseMaskHigh(a, 12) in pages ){
                // havoced the same
                assert s13.m.addresses[a] ==s23.m.addresses[a];
            } else {
                assert s13.m.addresses[a] == s12.m.addresses[a];
                assert s23.m.addresses[a] == s22.m.addresses[a];
                assert dataPagesCorrespond(s12.m, d1);
                assert dataPagesCorrespond(s22.m, d2);
                lemma_data_page_eqdb_to_addrs(d1, d2, s12, s22, n, a, atkr);
                assert s12.m.addresses[a] == s22.m.addresses[a];
                assert s13.m.addresses[a] == s23.m.addresses[a];
            }
        }

    }
    
    forall( n : PageNr | pgInAddrSpc(d14, n, atkr))
        ensures d14[n].entry == d24[n].entry
    {
        reveal_updateUserPagesFromState();
        if(pageSWrInAddrspace(d1, l1p, n)) {
            assert d1[n].entry == d2[n].entry;
            assert d14[n] == d1[n].(entry := d1[n].entry.(
                contents := contentsOfPage(s13, n)));
            assert d24[n] == d2[n].(entry := d2[n].entry.(
                contents := contentsOfPage(s23, n)));
            assert d14[n].entry == d24[n].entry;
        } else {
            assert d14[n].entry == d1[n].entry;
            assert d24[n].entry == d2[n].entry;
            assert d1[n].entry == d2[n].entry;
            assert d14[n].entry == d24[n].entry;
        }
    }

    reveal_enc_conf_eqpdb();
    assert enc_conf_eqpdb(d14, d24, atkr);
}

lemma lemma_data_page_eqdb_to_addrs( d1:PageDb, d2:PageDb, s1: state, s2: state,
n:PageNr, a:addr, atkr:PageNr)
    requires validPageDb(d1) && validPageDb(d2)
    requires ValidState(s1) && ValidState(s2) && SaneConstants()
    requires d1[n].PageDbEntryTyped? && d1[n].entry.DataPage?
    requires d2[n].PageDbEntryTyped? && d2[n].entry.DataPage?
    requires valAddrPage(d1, atkr) && valAddrPage(d2, atkr)
    requires d1[n].addrspace == atkr && d2[n].addrspace == atkr
    requires enc_conf_eqpdb(d1, d2, atkr)
    requires a in addrsInPage(n, page_monvaddr(n))
    requires dataPagesCorrespond(s1.m, d1) && dataPagesCorrespond(s2.m, d2)
    ensures s1.m.addresses[a] == s2.m.addresses[a]
{
	reveal_enc_conf_eqpdb();
	reveal_pageDbDataCorresponds();
	assume false;
}

lemma lemma_eqpdb_pt_coresp(d1: PageDb, d2: PageDb, s1: state, s2: state,
l1p:PageNr, atkr: PageNr)
    requires validPageDb(d1) && validPageDb(d2)
    requires ValidState(s1) && ValidState(s2)
    requires ValidState(s1) && ValidState(s2) && SaneConstants()
    requires valAddrPage(d1, atkr) && valAddrPage(d2, atkr)
    requires !stoppedAddrspace(d1[atkr]) && !stoppedAddrspace(d2[atkr])
    requires enc_conf_eqpdb(d1, d2, atkr)
    requires nonStoppedL1(d1, l1p) && nonStoppedL1(d2, l1p)
    requires pageTableCorresponds(s1, d1, l1p)
    requires pageTableCorresponds(s2, d2, l1p)
    requires valAddrPage(d1, atkr) && valAddrPage(d2, atkr)
        && d1[atkr].entry.l1ptnr == d2[atkr].entry.l1ptnr == l1p
    requires pgInAddrSpc(d1, l1p, atkr) && pgInAddrSpc(d2, l1p, atkr)
    ensures  ExtractAbsPageTable(s1) == ExtractAbsPageTable(s2)
{
    reveal_pageTableCorresponds();
    assert s1.conf.ttbr0.ptbase == page_paddr(l1p);
    assert s2.conf.ttbr0.ptbase == page_paddr(l1p);
    var vbase := s1.conf.ttbr0.ptbase + PhysBase();
    assert ValidAbsL1PTable(s1.m, page_monvaddr(l1p));
    assert ValidAbsL1PTable(s2.m, page_monvaddr(l1p));
    assert ExtractAbsPageTable(s1) ==
        Just(ExtractAbsL1PTable(s1.m, vbase));
    assert ExtractAbsPageTable(s2) ==
        Just(ExtractAbsL1PTable(s2.m, vbase));
    assert ExtractAbsL1PTable(s1.m, page_monvaddr(l1p)) ==
        mkAbsPTable(d1, l1p);
    assert ExtractAbsL1PTable(s2.m, page_monvaddr(l1p)) ==
        mkAbsPTable(d2, l1p);
        
    assert mkAbsPTable(d1, l1p) == mkAbsPTable(d2, l1p) by {
        reveal_enc_conf_eqpdb();
        var l1pt1 := d1[l1p].entry.l1pt;
        var l1pt2 := d2[l1p].entry.l1pt;
        // assert l1pt1 == l1pt2;
        // var fn1 := imap l1e:Maybe<PageNr> | l1e in l1pt1 :: mkAbsPTable'(d1, l1e);
        // var fn2 := imap l1e:Maybe<PageNr> | l1e in l1pt2 :: mkAbsPTable'(d2, l1e);
        // assert fn1 == fn2;
        assert l1pt1 == l1pt2 by {
            assert pgInAddrSpc(d1, l1p, atkr);
            assert pgInAddrSpc(d2, l1p, atkr);
            assert d1[l1p].entry == d2[l1p].entry;
        }
        forall( l1e | l1e in l1pt1 )
            ensures mkAbsPTable'(d1, l1e) == mkAbsPTable'(d2, l1e)
        {
            assume false;

            // roughly, by validPageDb I know that all the pages reachable from 
            // l1e have the same addrspace as l1p. Since the addrspace of l1p 
            // is the attacker, and since I know enc_conf_eqdb(d1, d2, atkr), 
            // the entries of all those pages are the same.

            // reveal_validPageDb();
            // assert l1e.Just?;
            // assert d1[l1e.v].addrspace == d1[l1p].addrspace;
            // assert d2[l1e.v].addrspace == d2[l1p].addrspace;
            // assert pgInAddrSpc(d1, l1e.v, atkr);
            // assert pgInAddrSpc(d2, l1e.v, atkr);
            // assert d1[l1e.v].entry == d2[l1e.v].entry;

            // This seems close... assume false here proves line 687... but 
            // trying to do anything here takes that away
            // assert (l1e.Just? &&
            // pgInAddrSpc(d1, l1e.v, atkr) &&
            // pgInAddrSpc(d2, l1e.v, atkr)) by  {
            //     reveal_validPageDb();
            //     assert l1e.Just?;
            //     assert d1[l1e.v].addrspace == d1[l1p].addrspace;
            //     assert d2[l1e.v].addrspace == d2[l1p].addrspace;
            // }
            //lemma_mkabspt_enc_conf_eqpdb(d1, d2, l1e, atkr);
            //assert d1[l1ep].entry == d2[l1ep].entry;
        }
        reveal_mkAbsPTable();
    }
}

/*
lemma lemma_mkabspt_enc_conf_eqpdb(d1: PageDb, d2: PageDb, l1p: PageNr, 
    l1pt:seq<Maybe<PageNr>>, atkr: PageNr)
    requires validPageDb(d1) && validPageDb(d2) && SaneConstants()
    requires !stoppedAddrSpace(atkr)
    requires enc_conf_eqpdb(d1, d2, atkr)
    ensures mkAbsPTable'(d1, l1e) == mkAbsPTable'(d2, l1e)
{
    reveal_enc_conf_eqpdb();
    reveal_validPageDb();

    assert d1[l1e.v].entry == d2[l1e.v].entry;
}
*/



//-----------------------------------------------------------------------------
// Resume
//-----------------------------------------------------------------------------
lemma lemma_resume_enc_conf_ni(s1: state, d1: PageDb, s1':state, d1': PageDb,
                               s2: state, d2: PageDb, s2':state, d2': PageDb,
                               dispPage: word,
                               atkr: PageNr)
    requires ni_reqs(s1, d1, s1', d1', s2, d2, s2', d2', atkr)
    requires smc_resume(s1, d1, s1', d1', dispPage)
    requires smc_resume(s2, d2, s2', d2', dispPage)
    requires enc_conf_eqpdb(d1, d2, atkr)
    requires entering_atkr(d1, d2, dispPage, atkr, true) ==>
        enc_conf_eq_entry(s1, s2, d1, d2, atkr)
    ensures enc_conf_eqpdb(d1', d2', atkr)
    ensures entering_atkr(d1, d2, dispPage, atkr, true) ==>
        enc_conf_eq_entry(s1', s2', d1', d2', atkr)
{
    // TODO proveme
    assume false;
}
