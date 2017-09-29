# Youth Match Second Generation

 Automating a lottery which matches local young people to meaningful (summer) employment, and tracking their responses.

## Setup

You will need to setup a .env file with some API keys. We use MapZen for geocoding, Twilio for text messaging, and iCIMS is the app we interface with from the City of Boston. See config/secrets.yml for the list of API key variables.

To test and prove the lottery works:

1. `rake import:applicant_test_data`
2. `rake import:position_test_data`
3. `rake lottery:assign_lottery_numbers` to pick lottery winners
4. `rake lottery:build_preference_lists` to build preference lists
5. `rake lottery:match` to match positions to jobs
6. `rake lottery:print` to print information about the lottery results


## Contact

[Matt Zagaja](mzagaja@mapc.org), Lead Civic Web Developer, MAPC.

### Credits

This project is funded by the Civic Technology and Data Collaborative grant, provided by [Living Cities][lc], [Code for America][cfa], and the [National Neighborhood Indicators Partnership][nnip], with matching support from [BNY Mellon][bny].

[lc]: https://www.livingcities.org/
[cfa]: https://codeforamerica.org
[nnip]: http://www.neighborhoodindicators.org/
[bny]: https://www.bnymellon.com/

### Contributing

We strongly encourage contributions -- we believe that your code can make this project better!

Get in touch by filing an issue, submitting a pull request, or emailing us.
