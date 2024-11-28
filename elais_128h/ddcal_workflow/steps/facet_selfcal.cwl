cwlVersion: v1.2
class: CommandLineTool
id: facet_selfcal
label: Facet Selfcal
doc: |
    Performs direction independent calibration
    of the international antenna array.

baseCommand:
    - python3

inputs:
    - id: msin
      type: Directory
      doc: |
        Input data phase-shifted to the
        delay calibrator in MeasurementSet format.
      inputBinding:
        position: 6

    - id: skymodel
      type: File?
      doc: |
        The skymodel to be used in the first
        cycle in the self-calibration.
      inputBinding:
        prefix: "--skymodel"
        position: 2
        itemSeparator: " "
        separate: true

    - id: configfile
      type: File
      doc: A plain-text file containing configuration options for self-calibration.
      inputBinding:
        prefix: "--configpath"
        position: 3
        itemSeparator: " "
        separate: true

    - id: dde_directions
      type: File?
      doc: A text file with directions for DDE calibration with facetselfcal
      inputBinding:
        prefix: "--facetdirection"
        position: 4
        itemSeparator: " "
        separate: true

    - id: selfcal
      type: Directory
      doc: External self-calibration script.
      inputBinding:
        prefix: "--helperscriptspath"
        position: 5
        itemSeparator: " "
        separate: true

    - id: h5merger
      type: Directory
      doc: External LOFAR helper scripts for merging HDF5 files.
      inputBinding:
        prefix: "--helperscriptspathh5merge"
        position: 6
        itemSeparator: " "
        separate: true

outputs:
    - id: h5parm
      type: File
      outputBinding:
        glob: merged_addCS*006*.h5
      doc: |
        The calibration solution files generated
        by lofar_facet_selfcal in HDF5 format.

    - id: images
      type: File[]
      outputBinding:
        glob: ['*.png', plotlosoto*/*.png]
      doc: |
        Delay calibrator images generated by lofar_facet_selfcal.

    - id: fits_images
      type: File[]
      outputBinding:
        glob: '*MFS-image.fits'

    - id: logfile
      type: File[]
      outputBinding:
         glob: [facet_selfcal*.log, selfcal.log]
      doc: |
        The files containing the stdout
        and stderr from the step.

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.msin)
        writable: true
      - entry: $(inputs.configfile)
        writable: false

arguments:
  - $( inputs.selfcal.path + '/facetselfcal.py' )

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl
  - class: ResourceRequirement
    coresMin: 15

stdout: facet_selfcal.log
stderr: facet_selfcal_err.log
