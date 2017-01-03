/**
*
* @file  /model/services/abuseIPDBService.cfc
* @author  Denard Springle (denard.springle@gmail.com)
* @description I am an API wrapper for AbuseIPDB.com's (https://abuseipdb.com/api.html) IP abuse database
*
*/

property endpointUrl;
property apiKey;

component output="false" displayname="abuseIPDBService"  {

	/**
	* @displayname	init
	* @description	I initialize the service with your API key
	* @param		apiKey {String} required - I am the API key provided to you by abuseipdb.com
	* @param 		endpointUrl {String} default: https://www.abuseipdb.com/ - I am the endpoint URL
	* @return		this
	*/
	public function init( required string apiKey, string endpointUrl = 'https://www.abuseipdb.com/' ) {
		
		variables.endpointUrl = arguments.endpointUrl;
		variables.apiKey = arguments.apiKey;

		return this;
	}

	/**
	* @displayname	checkIP
	* @description	I call the API's check method and return an array of abuse reports
	* @param		ipAddress {String} required - I am the IP address to check with abuseipdb.com
	* @param 		days {Numeric} default: 30 - I am the number of days prior to today to check for abuse
	* @return		any
	*/
	public any function checkIP( required string ipAddress, numeric days = 30 ) {

		// set up http service
		var httpService = new http();
		var apiResult = arrayNew(1);

		// set properties of http request
		httpService.setMethod( 'POST' );
		httpService.setCharset( 'UTF-8' );
		// set the url to the endpoint, adding the ip address and required parameters
		httpService.setUrl( variables.endpointUrl & 'check/' & arguments.ipAddress & '/json' );

		// add the api key and number of days as form field parameters
		httpService.addParam( name = 'key', type = 'formfield', value = variables.apiKey );
		httpService.addParam( name = 'days', type = 'formfield', value = arguments.days );

		// try to make the http call
		try {

			// and deserialize the result
			apiResult = deserializeJSON( httpService.send().getPrefix().fileContent );

		// catch any errors
		} catch( any e ) {
			// dump the error and exit
			writeDump( e );
			abort;
		}

		// return the result of the api call (struct for single result, 
		// array of structs for multiple results, or empty array if no abuse reported)
		// each struct includes: ip, country, iso (country code), category (comma delimited list 
		// of abuse categories) and created (timestamp when it was reported)
		return apiResult;

	}

	/**
	* @displayname	reportIP
	* @description	I call the API's report method to report abuse by an IP
	* @param		ipAddress {String} required - I am the IP address to report to abuseipdb.com
	* @param 		categoryList {String} required - I am the comma separated list of abuse categories being reported
	* @param 		comment {String} - I am an additional comment about this abuse to log with this report
	* @return		struct
	*/
	public struct function reportIP( required string ipAddress, required string categoryList, string comment = '' ) {

		// set up http service
		var httpService = new http();
		var apiResult = structNew();

		// set properties of http request
		httpService.setMethod( 'POST' );
		httpService.setCharset( 'UTF-8' );
		// set the url to the endpoint, adding required parameters
		httpService.setUrl( variables.endpointUrl & 'report/json' );

		// add the api key, ip address and categoryList as form field parameters
		httpService.addParam( name = 'key', type = 'formfield', value = variables.apiKey );
		httpService.addParam( name = 'ip', type = 'formfield', value = variables.ipAddress );
		httpService.addParam( name = 'category', type = 'formfield', value = arguments.categoryList );

		// check if a comment is being passed in
		if( len( trim( arguments.comment ) ) ) {
			// it is, add the comment as a form field parameter
			httpService.addParam( name = 'comment', type = 'formfield', value = trim( arguments.comment ) );
		}

		// try to make the http call
		try {

			// and deserialize the result
			apiResult = deserializeJSON( httpService.send().getPrefix().fileContent );

		// catch any errors
		} catch( any e ) {
			// dump the error and exit
			writeDump( e );
			abort;
		}

		// return the result of the call (struct with 'ip' and 'success' fields)
		return apiResult;

	}

	/**
	* @displayname	getAbuseCategories
	* @description	I return an array of structs containing the abuse categories for abuseipdb.com
	* @return		array
	*/
	public array function getAbuseCategories() {

		// get the abuse categories from the cache
		var categoryCache = cacheGet( 'abuseipdb_categories' );

		// check if the cached version exists 
		if( isNull( categoryCache ) ) {
			// it doesn't exist, generate an array of structs
			// see: https://abuseipdb.com/categories
			categoryCache = arrayNew(1);
			categoryCache[1] = { id = 3, title = 'Fraud Orders', description = 'Fraudulent orders.' },
			categoryCache[2] = { id = 4, title = 'DDoS Attack', description = 'Participating in distributed denial-of-service (usually part of botnet).' },
			categoryCache[3] = { id = 9, title = 'Open Proxy', description = 'Open proxy, open relay, or Tor exit node.' },
			categoryCache[4] = { id = 10, title = 'Web Spam', description = 'Comment/forum spam, HTTP referer spam, or other CMS spam.' },
			categoryCache[5] = { id = 11, title = 'Email Spam', description = 'Spam email content, infected attachments, phishing emails, and spoofed senders (typically via exploited host or SMTP server abuse). Note: Limit comments to only relevent information (instead of log dumps) and be sure to remove PII if you want to remain anonymous.' },
			categoryCache[6] = { id = 14, title = 'Port Scan', description = 'Scanning for open ports and vulnerable services.' },
			categoryCache[7] = { id = 18, title = 'Brute-Force', description = 'Credential brute-force attacks on webpage logins and services like SSH, FTP, SIP, SMTP, RDP, etc. This category is seperate from DDoS attacks.' },
			categoryCache[8] = { id = 19, title = 'Bad Web Bot', description = 'Webpage scraping (for email addresses, content, etc) and crawlers that do not honor robots.txt. Excessive requests and user agent spoofing can also be reported here.' },
			categoryCache[9] = { id = 20, title = 'Exploited Host', description = 'Host is likely infected with malware and being used for other attacks or to host malicious content. The host owner may not be aware of the compromise. This category is often used in combination with other attack categories.' },
			categoryCache[10] = { id = 21, title = 'Web App Attack', description = 'Attempts to probe for or exploit installed web applications such as a CMS like WordPress/Drupal, e-commerce solutions, forum software, phpMyAdmin and various other software plugins/solutions.' },
			categoryCache[11] = { id = 22, title = 'SSH', description = 'Secure Shell (SSH) abuse. Use this category in combination with more specific categories.' },
			categoryCache[12] = { id = 23, title = 'IoT Targeted', description = 'Abuse was targeted at an "Internet of Things" type device. Include information about what type of device was targeted in the comments.' }				
			];
			// and cache the abuse categories for 90/45 days
			cachePut( 'abuseipdb_categories', categoryCache, createTimeSpan( 90, 0, 0, 0 ), createTimeSpan( 45, 0, 0, 0 ) );
		}

		// return the array of abuse categories
		return categoryCache;
	}

}