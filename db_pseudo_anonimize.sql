update User_ set
	reminderQueryAnswer = '42',
	agreedToTermsOfUse = 1,
	loginIP = '000.00.00.000',
	lastLoginIP = '000.00.00.000',
	emailAddress = concat(userId , '@mail.invalid'),
	greeting = 'Not a real user',
	firstName = concat(userId, '-firstName'),
	middleName = '',
	lastName = concat(userId, '-lastName'),
	portraitId = 0,
	password_ = 'test',
	passwordEncrypted = 0;
 
update Portlet set active_ = 1 where portletId = '58';
 
update PortalPreferences set preferences =
	replace(preferences, 'mail.lokaal', 'smtp.invalid')
	where preferences like '%mail.lokaal%';

update PortalPreferences set preferences =
	replace(preferences, '@ou.nl', '@mail.invalid')
	where preferences like '%@ou.nl%';

update Company set mx =
	concat(companyId, 'mx.invalid');
