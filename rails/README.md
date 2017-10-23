# Youth Match Second Generation

 Automating a lottery which matches local young people to meaningful (summer) employment, and tracking their responses.

## Setup

You will need to setup a .env file with some API keys. We use MapZen for geocoding, Twilio for text messaging, and iCIMS is the app we interface with from the City of Boston. See config/secrets.yml for the list of API key variables.

To calculate the travel time preferences you will need to setup instances of Graphhopper or another routing engine that can calculate travel times between two latitude and longitude points. MAPC has developed a system that has two Graphhopper instances deployed to AWS. One instance is a public transit instance that is c4.4xlarge instance, the other is a c4.large instance that does the calculations for walking transit directions. These two instances sit behind an AWS application load balancer that directs the requests to the appropriate Graphhopper instance [based on the "vehicle" parameter in the URL](http://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html#listener-rules). The endpoint and parameters for calculating travel times can be changed by modifying build_travel_time_preference_job.rb.

In order to create partner accounts, someone needs to run the rake task rake email:create_cbo_accounts. This will then import the partner emails from a file called partner-emails-6-fixed.csv which contains the following columns: Organization Name, Primary Contact Person, Primary Contact Email. A new CSV file can be substituted that has data for this year. It just needs to match the "Organization Name" in the CSV with the correct "site_name" that is imported in the Positions table. The positions should be imported before importing partner accounts.

To test and prove the lottery works:

1. `rake import:applicant_test_data`
2. `rake import:position_test_data`
3. `rake lottery:assign_lottery_numbers` to pick lottery winners
4. `bundle exec sidekiq` to start sidekiq for background workers
5. `rake lottery:build_travel_time_preferences` to build travel time preference lists
6. `rake lottery:build_preference_scores` to build the final preference scores
8. `rake lottery:match` to match positions to jobs
9. `rake lottery:print` to print information about the lottery results

## Algorithm Explanation

Our algorithm works in the following manner:

We geolocate the addresses of the young people and positions using Mapzen. Then we run a "travel time" score calculation for the distance between an applicant and a position based on how long it would take the applicant to get to the job site. We store this calculation as a floating point number between 5 and -5. If the applicant cares about travel time we assign the calculation based on the following formula:

`minutes < 30 ? (0.008 * (minutes ** 2)) - (0.5833 * minutes) + 5 : -5`

If they do not care then we use this formula:

`minutes < 40 ? (-0.25 * minutes) + 5 : -5`

This is then used to calculate a preference store that is based on two components:

1. A normalized travel time score
2. An overlapping interest score

The normalized travel time score involves ranking the travel time scores for an applicant relative to all the job sites. We then calculate a new score by dividing the travel time score rank index number by an interval that gives us a score of -5 to 5.

Finally, we add the interest score. If there is interest score overlap and interest score is important we add 5 points. If interest score is ranked less important than travel time score we add 3. Otherwise if there is no overlap we subtract 3 or 5.

After we've calculated these scores we apply the Gale-Shapely algorithm to place applicants with positions. We implement Gale-Shapely by taking an applicant and iterating over each position until we find either an open position or a position where the applicant ranks more highly as a match than the current applicant. We then repeat this process for each unplaced applicant until all applicants are placed.

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