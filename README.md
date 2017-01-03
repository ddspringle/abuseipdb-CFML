# AbuseIPDB CFML
This repository includes a CFC called abuseIPDBService.cfc that makes use of the AbuseIPDB blacklist API - this blacklist maintains the IP addresses that have been associated with malicious activity online.

## Usage

To use this wrapper, simply initialize it with your API key provided by AbuseIPDB, as follows:

    // get the abuseIPDBService
    abuseIPDBService = createObject( 'component', 'abuseIPDBService').init( apiKey = '[API_KEY]' );

### Check IP for abuse

You can call the service with the IP address you wish to check, as follows:

    // get the structure as a variable from the httpBL service    
	returnStruct = abuseIPDBService.checkIP( ipAddress = [IP_ADDRESS] [, days = 30 ] );

The checkIp function returns either a struct if only one report exists within the days requested, an array of structs if more than one independant report and an empty array if there is no result. Structs will have the following keys:

    ip: This simply reflects the ip address you requested
    country: The name of the country where this IP is assigned
    isoCode: The 2-letter ISO country code for the country
    category: An array of integer category id's (see: [categories](https://abuseipdb.com/categories))
    created: The date and time of the report

You can pass an optional `days` argument to checkIp to set the number of days back to report on. The default is 30 days.

### Report IP for abuse

You can also report the IP addresses that you have found performing malicious activity against your site to the blacklist, by passing in the IP address, a comma delimited list of category ints and your reason for taking local action against this IP address (e.g. 'performing SQL injection attempts') as follows:

	// report an ip address to the blacklist for abuse
	reportStruct = abuseIPDBService.reportIP( 
		ipAddress = [IP address to report], 
		categoryList = [comma delim category ints],
		comment = [Your reason for taking local action against the IP]
	);

The reportIP function returns a struct with success indication.

### Get AbuseIPDB categories

You can also get an array of [categories](https://abuseipdb.com/categories) from this wrapper, as follows:

	// get array of abuse category structs
	abuseCatArray = abuseIPDBService.getAbuseCategories();


**NOTE**: You should [read the abuseIPDB API documentation](https://abuseipdb.com/api.html) for more information about the API.

## Compatibility

* Adobe ColdFusion 11+
* Lucee 4.5+

## Bugs and Feature Requests

If you find any bugs or have a feature you'd like to see implemented in this code, please use the issues area here on GitHub to log them.

## Contributing

This project is actively being maintained and monitored by Denard Springle. If you would like to contribute to this project please feel free to fork, modify and send a pull request!

## License

The use and distribution terms for this software are covered by the Apache Software License 2.0 (http://www.apache.org/licenses/LICENSE-2.0).
