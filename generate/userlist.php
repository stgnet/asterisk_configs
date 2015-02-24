<?php

require_once 'vendor/autoload.php';
$faker = Faker\Factory::create('en_US');

require 'valid_area_codes.php';

$keypad_letter_to_digit = array(
	'a' => '2', 'b' => '2', 'c' => '2',
	'd' => '3', 'e' => '3', 'f' => '3',
	'g' => '4', 'h' => '4', 'i' => '4',
	'j' => '5', 'k' => '5', 'l' => '5',
	'm' => '6', 'n' => '6', 'o' => '6',
	'p' => '7', 'q' => '7', 'r' => '7', 's' => '7',
	't' => '8', 'u' => '8', 'v' => '8',
	'w' => '9', 'x' => '9', 'y' => '9', 'z' => '9'
);

function extensionFromName($fname, $lname)
{
	global $keypad_letter_to_digit;
	$ignore = array('\'');
	$fname = strtolower($fname);
	$lname = str_replace($ignore, '', strtolower($lname));

	$name = substr($fname, 0, 1) . substr($lname, 0, 3);

	$ext = '';
	for ($i=0; $i<strlen($name); $i++) {
		$letter = $name[$i];
		if (empty($keypad_letter_to_digit[$letter])) {
			return '0000';
		}
		$ext .= $keypad_letter_to_digit[$letter];
	}
	return $ext;
}

function cleanPhone($phone)
{
	$strip=array('(', ')', '-', '.', ' ');
	$phone = str_replace($strip, "", $phone);

	if ($phone[0] == '1') {
		$phone = substr($phone, 1);
	}
	if ($phone[0] == '0') {
		$phone = substr($phone, 1);
	}

	return $phone;
}
function validPhone($phone)
{
	global $valid_area_codes;

	if (strlen($phone) != 10) {
		return false;
	}
	// npa must be valid
	$ac = substr($phone, 0, 3);
	if (!in_array($ac, $valid_area_codes)) {
		return false;
	}
	// nxx cannot start with 0 or 1
	$n = substr($phone, 3, 1);
	if ($n == 0 || $n == 1) {
		return false;
	}
	$nxx = substr($phone, 3, 3);
	// nxx cannot be 555
	if ($nxx == '555') {
		return false;
	}
	return true;
}

function validExt($number)
{
	if ($number[0] == '0') {
		return false;
	}
	if ($number[1] == '1') {
		return false;
	}
	if (strlen($number) == 3) {
		if ($number[1] == '1' && $number[2] == '1') {
			return false;
		}
	}
	return true;
}



$users=array();

while (count($users) < 2000)
{
	$phone = $valid_area_codes[array_rand($valid_area_codes)];
	$phone .= $faker->numberBetween(2000000,9999999);
	if (!validPhone($phone)) {
		//echo "INVALID PHONE: ".$phone."\n";
		continue;
	}
	$fname = $faker->firstName;
	$lname = $faker->lastName;

	$vmpin = $faker->numerify('####');

	$ext = extensionFromName($fname, $lname);
	$ext3 = substr($ext, 0, 3);

	if (empty($users[$ext3])) {
		if (validExt($ext3)) {
			$ext = $ext3;
		}
	}
	if (!validExt($ext)) {
		echo "Ext $ext is not valid\n";
		continue;
	}
	if (!empty($users[$ext])) {
		//echo "Ext $ext already exists\n";
		continue;
	}
	$user = array(
		'extension' => $ext,
		'pin' => $vmpin,
		'name' => $fname.' '.$lname,
		'email' => strtolower($fname).'.'.strtolower($lname).'@example.org',
		'did' => $phone,
	);
	//print_r($user);
	$users[$ext]=$user;
	echo count($users)."\n";
}

ksort($users);
$fp=fopen("users.csv","w");
fputcsv($fp,array_keys($user));
foreach ($users as $user) {
	fputcsv($fp,$user);
}
fclose($fp);

