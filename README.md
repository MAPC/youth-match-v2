# Youth Match Second Generation

 Automating a lottery which matches local young people to meaningful (summer) employment, and tracking their responses.

## Setup

You will need to setup a .env file with some API keys. We use MapZen for geocoding, Twilio for text messaging, and iCIMS is the app we interface with from the City of Boston. See config/secrets.yml for the list of API key variables.

To calculate the travel time preferences you will need to setup instances of Graphhopper or another routing engine that can calculate travel times between two latitude and longitude points. MAPC has developed a system that has two Graphhopper instances deployed to AWS. One instance is a public transit instance that is c4.4xlarge instance, the other is a c4.large instance that does the calculations for walking transit directions. These two instances sit behind an AWS application load balancer that directs the requests to the appropriate Graphhopper instance based on the "vehicle" parameter in the URL. The endpoint and parameters for calculating travel times can be changed by modifying build_travel_time_preference_job.rb.

To test and prove the lottery works:

1. `rake import:applicant_test_data`
2. `rake import:position_test_data`
3. `rake lottery:assign_lottery_numbers` to pick lottery winners
4. `rake lottery:build_travel_time_preferences` to build travel time preference lists
5. `rake lottery:build_preference_scores` to build the final preference scores
6. `rake lottery:match` to match positions to jobs
7. `rake lottery:print` to print information about the lottery results

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
