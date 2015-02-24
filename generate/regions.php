<?php

// generate list of valid area codes

require 'valid_area_codes.php';

$us_fifty_regions=array(
	'AL',
	'AK',
	'AZ',
	'AR',
	'CA',
	'CO',
	'CT',
	'DE',
	'FL',
	'GA',
	'HI',
	'ID',
	'IL',
	'IN',
	'IA',
	'KS',
	'KY',
	'LA',
	'ME',
	'MD',
	'MA',
	'MI',
	'MN',
	'MS',
	'MO',
	'MT',
	'NE',
	'NV',
	'NH',
	'NJ',
	'NM',
	'NY',
	'NC',
	'ND',
	'OH',
	'OK',
	'OR',
	'PA',
	'RI',
	'SC',
	'SD',
	'TN',
	'TX',
	'UT',
	'VT',
	'VA',
	'WA',
	'WV',
	'WI',
	'WY'
);


$ac_region = array();

$us_area_codes = array();
$non_us_area_codes = array();

foreach ($valid_area_codes as $ac)
{
	$url = 'http://localcallingguide.com/xmlrc.php?npa='.$ac;
	$xml = file_get_contents($url);
	$data = simplexml_load_string($xml);

	$regions = array();

	foreach ($data->rcdata as $rc) {
		$region = (string)$rc->region;
		if (!in_array($region, $regions)) {
			$regions[] = $region;
		}
	}
	$ac_region[$ac] = implode(',', $regions);

	if (in_array($ac_region[$ac], $us_fifty_regions)) {
		$us_area_codes[] = $ac;
	} else {
		$non_us_area_codes[] = $ac;
	}
}

function store_var($var, $value)
{
	$output='<'.'?php'."\n";
	$output.='// generated by '.$_SERVER['PHP_SELF']."\n";
	$output.='$'.$var.' = '.var_export($value, true).";\n";
	file_put_contents($var.'.php', $output);
}

store_var('area_code_region', $ac_region);

store_var('us_area_codes', $us_area_codes);
store_var('non_us_area_codes', $non_us_area_codes);

