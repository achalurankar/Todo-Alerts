public with sharing class DateUtil {
    public DateUtil() {

    }

    public static string getDisplayDate(DateTime taskTime) {
        string[] monthlist = new string[]{ 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec' };
        string display = '';
        string day = taskTime.day() + '';
        string month = monthlist[taskTime.month() - 1] + '';
        string year = taskTime.year() + '';
        string hour = taskTime.hour() + '';
        string minute = taskTime.minute() + '';
        display += day + ' ';
        display += month + ' ';
        display += year + ' ';
        // todo change format to 12hr
        display += hour + ':';
        display += minute;
        return display;
    }
}