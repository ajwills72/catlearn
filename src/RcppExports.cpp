// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <RcppArmadillo.h>
#include <Rcpp.h>

using namespace Rcpp;

// slpBM
List slpBM(List st, NumericMatrix tr, bool xtdo);
RcppExport SEXP _catlearn_slpBM(SEXP stSEXP, SEXP trSEXP, SEXP xtdoSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< List >::type st(stSEXP);
    Rcpp::traits::input_parameter< NumericMatrix >::type tr(trSEXP);
    Rcpp::traits::input_parameter< bool >::type xtdo(xtdoSEXP);
    rcpp_result_gen = Rcpp::wrap(slpBM(st, tr, xtdo));
    return rcpp_result_gen;
END_RCPP
}
// slpEXIT
List slpEXIT(List st, DataFrame tr, bool xtdo);
RcppExport SEXP _catlearn_slpEXIT(SEXP stSEXP, SEXP trSEXP, SEXP xtdoSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< List >::type st(stSEXP);
    Rcpp::traits::input_parameter< DataFrame >::type tr(trSEXP);
    Rcpp::traits::input_parameter< bool >::type xtdo(xtdoSEXP);
    rcpp_result_gen = Rcpp::wrap(slpEXIT(st, tr, xtdo));
    return rcpp_result_gen;
END_RCPP
}
// slpLMSnet
Rcpp::List slpLMSnet(List st, mat tr, bool xtdo);
RcppExport SEXP _catlearn_slpLMSnet(SEXP stSEXP, SEXP trSEXP, SEXP xtdoSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< List >::type st(stSEXP);
    Rcpp::traits::input_parameter< mat >::type tr(trSEXP);
    Rcpp::traits::input_parameter< bool >::type xtdo(xtdoSEXP);
    rcpp_result_gen = Rcpp::wrap(slpLMSnet(st, tr, xtdo));
    return rcpp_result_gen;
END_RCPP
}
// slpMack75
List slpMack75(List st, NumericMatrix tr, bool xtdo);
RcppExport SEXP _catlearn_slpMack75(SEXP stSEXP, SEXP trSEXP, SEXP xtdoSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< List >::type st(stSEXP);
    Rcpp::traits::input_parameter< NumericMatrix >::type tr(trSEXP);
    Rcpp::traits::input_parameter< bool >::type xtdo(xtdoSEXP);
    rcpp_result_gen = Rcpp::wrap(slpMack75(st, tr, xtdo));
    return rcpp_result_gen;
END_RCPP
}
// slpRW
List slpRW(List st, NumericMatrix tr, bool xtdo);
RcppExport SEXP _catlearn_slpRW(SEXP stSEXP, SEXP trSEXP, SEXP xtdoSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< List >::type st(stSEXP);
    Rcpp::traits::input_parameter< NumericMatrix >::type tr(trSEXP);
    Rcpp::traits::input_parameter< bool >::type xtdo(xtdoSEXP);
    rcpp_result_gen = Rcpp::wrap(slpRW(st, tr, xtdo));
    return rcpp_result_gen;
END_RCPP
}
// slpALCOVE
List slpALCOVE(List st, NumericMatrix tr, std::string dec, bool humble, bool attcon, double absval, bool xtdo);
RcppExport SEXP _catlearn_slpALCOVE(SEXP stSEXP, SEXP trSEXP, SEXP decSEXP, SEXP humbleSEXP, SEXP attconSEXP, SEXP absvalSEXP, SEXP xtdoSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< List >::type st(stSEXP);
    Rcpp::traits::input_parameter< NumericMatrix >::type tr(trSEXP);
    Rcpp::traits::input_parameter< std::string >::type dec(decSEXP);
    Rcpp::traits::input_parameter< bool >::type humble(humbleSEXP);
    Rcpp::traits::input_parameter< bool >::type attcon(attconSEXP);
    Rcpp::traits::input_parameter< double >::type absval(absvalSEXP);
    Rcpp::traits::input_parameter< bool >::type xtdo(xtdoSEXP);
    rcpp_result_gen = Rcpp::wrap(slpALCOVE(st, tr, dec, humble, attcon, absval, xtdo));
    return rcpp_result_gen;
END_RCPP
}
// slpCOVIS
List slpCOVIS(List st, NumericMatrix tr, bool crx, bool respt, bool rgive, bool xtdo);
RcppExport SEXP _catlearn_slpCOVIS(SEXP stSEXP, SEXP trSEXP, SEXP crxSEXP, SEXP resptSEXP, SEXP rgiveSEXP, SEXP xtdoSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< List >::type st(stSEXP);
    Rcpp::traits::input_parameter< NumericMatrix >::type tr(trSEXP);
    Rcpp::traits::input_parameter< bool >::type crx(crxSEXP);
    Rcpp::traits::input_parameter< bool >::type respt(resptSEXP);
    Rcpp::traits::input_parameter< bool >::type rgive(rgiveSEXP);
    Rcpp::traits::input_parameter< bool >::type xtdo(xtdoSEXP);
    rcpp_result_gen = Rcpp::wrap(slpCOVIS(st, tr, crx, respt, rgive, xtdo));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_catlearn_slpBM", (DL_FUNC) &_catlearn_slpBM, 3},
    {"_catlearn_slpEXIT", (DL_FUNC) &_catlearn_slpEXIT, 3},
    {"_catlearn_slpLMSnet", (DL_FUNC) &_catlearn_slpLMSnet, 3},
    {"_catlearn_slpMack75", (DL_FUNC) &_catlearn_slpMack75, 3},
    {"_catlearn_slpRW", (DL_FUNC) &_catlearn_slpRW, 3},
    {"_catlearn_slpALCOVE", (DL_FUNC) &_catlearn_slpALCOVE, 7},
    {"_catlearn_slpCOVIS", (DL_FUNC) &_catlearn_slpCOVIS, 6},
    {NULL, NULL, 0}
};

RcppExport void R_init_catlearn(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
