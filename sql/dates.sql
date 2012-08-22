/* historical data */
SET @min_historical='20111214'; -- phase 3 of MoodBar deployed
SET @max_historical='20120523'; -- temporary UI enhancements deployed

/* treatment */
SET @min_treatment='20120523';
SET @max_treatment='20120613';

/* Note: users registered on 2012-06-14 are excluded from the analysis because
 * deployment takes some time and thus it is not possible to establish
 * which users had still the extension enabled and which had it not enabled.
 */

/* control group */
SET @min_control='20120615';
SET @max_control='20120629';

