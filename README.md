# ping-test

A bash ping tester to repeat a series of ping tests to a user defined series of sites.

The addresses to be used for the ping test can be easily updated, as is the number of pings to do for each site.

The results are displayed in the terminal window while as each site is completed. The results are also saved to a .txt file in the same location as the bash script using the date and time that it was executed at. This is ahdy to get comparisons over time with the same formatting and an exact timestamp.

The full script will also displ;ay information about the device from which the script is being run, inclusing local and oublic IP, device name and OS.

## Usage

- `sh pingTest.sh` shows device info and ping test results
- `sh pingTest.sh -l` limits the output to only the ping test results
