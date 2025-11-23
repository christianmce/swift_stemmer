// **************************************************************************
// FPorterStemmer.swift - August 2023
// Filter for perferming word stemming based on the Porter algorithm
// Copyright (c) 2023 Christian Mauricio Castillo Estrada (cmce at unach.mx)
// **************************************************************************

// This is the Porter stemming algorithm, ported to Python from the version coded up in ANSI C by the author. It may be be regarded
// as canonical, in that it follows the algorithm presented in Porter, 1980, An algorithm for suffix stripping, Program, Vol. 14,
// no. 3, pp 130-137, only differing from it at the points maked --DEPARTURE-- below.
// See also http://www.tartarus.org/~martin/PorterStemmer
// **************************************************************************
// The algorithm as described in the paper could be exactly replicated by adjusting the points of DEPARTURE, but this is barely necessary,
// because (a) the points of DEPARTURE are definitely improvements, and (b) no encoding of the Porter stemmer I have seen is anything like
// as exact as this version, even with the points of DEPARTURE!
