#!/usr/bin/env python3
# -*- coding: utf-8 -*-

__author__ = "Jurjen de Jong"

from argparse import ArgumentParser
import numpy as np
import pandas as pd
import casacore.tables as ct


def make_config(solint, ms):
    """
    Make config for facetselfcal

    Args:
        solint: solution interval
        ms: MeasurementSet

    """

    with ct.table(ms, readonly=True, ack=False) as t:
        time = np.unique(t.getcol('TIME'))

    deltime = np.abs(time[1]-time[0])

    # solint in minutes
    solint_scalarphase_1 = min(max(deltime/60, np.sqrt(solint)), 5)
    solint_scalarphase_2 = min(max(deltime/60, 2*np.sqrt(solint)), 8)
    solint_scalarphase_3 = min(max(1, 4*np.sqrt(solint)), 10)
    solint_complexgain_1 = max(16.0, 20*solint)

    # start ampsolve
    cg_cycle = 2

    if solint_complexgain_1/60 > 4:
        cg_cycle = 999
    elif solint_complexgain_1/60 > 3:
        solint_complexgain_1 = 240.

    smoothness_phase = 10.0

    if solint<3:
        smoothness_complex = 10.0
    else:
        smoothness_complex = 15.0

    # antenna groups
    if solint<0.3:
        stationgroup='core'
        uvmin=70000
    elif solint<1:
        stationgroup='coreandfirstremotes'
        uvmin=55000
    elif solint<3:
        stationgroup='coreandallbutmostdistantremotes'
        uvmin=40000
    else:
        stationgroup='alldutch'
        uvmin=25000

    script=f"""imagename                       = dd_selfcal
phaseupstations                 = 'core'
forwidefield                    = True
autofrequencyaverage            = True
update_multiscale               = True
soltypecycles_list              = [0,0,{cg_cycle}]
soltype_list                    = ['scalarphase','scalarphase','scalarphase','scalarcomplexgain']
smoothnessconstraint_list       = [{smoothness_phase},{smoothness_phase},{smoothness_phase*1.5},{smoothness_complex}]
smoothnessreffrequency_list     = [120.0,120.0,120.0,0.0]
smoothnessspectralexponent_list = [-1.0,-1.0,-1.0,-1.0]
solint_list                     = ['{int(solint_scalarphase_1*60)}s','{int(solint_scalarphase_2*60)}s','{int(solint_scalarphase_3*60)}s','{int(solint_complexgain_1*60)}s']
uvmin                           = {uvmin}
imsize                          = 2048
resetsols_list                  = ['alldutchandclosegerman','alldutch','{stationgroup}','{stationgroup}']
paralleldeconvolution           = 1024
targetcalILT                    ='scalarphase'
stop                            = 7
flagtimesmeared                 = True
compute_phasediffstat           = True
get_diagnostics                 = True
parallelgridding                = 6
"""

    if solint_scalarphase_1*60>64:
        script+='\navgtimestep                     = 64s'

    with open(ms+".config.txt", "w") as f:
        f.write(script)


def get_solint(ms, phasediff_output):
    """
    Get solution interval
    Args:
        ms: MeasurementSet
        phasediff_output: phasediff CSV output

    Returns: solution interval in minutes

    """

    phasediff = pd.read_csv(phasediff_output)
    sourceid = ms.split("_")[0]
    solint = phasediff[phasediff['Source_id'].str.split('_').str[0] == sourceid].best_solint.min()
    return solint


def parse_args():
    """
    Command line argument parser

    Returns: parsed arguments
    """

    parser = ArgumentParser(description='Make config')
    parser.add_argument('--ms', type=str, help='MeasurementSet')
    parser.add_argument('--phasediff_output', type=str, help='Phasediff CSV output')
    return parser.parse_args()


def main():
    """
    Main function
    """

    args = parse_args()

    solint = get_solint(args.ms, args.phasediff_output)
    make_config(solint, args.ms)


if __name__ == "__main__":
    main()