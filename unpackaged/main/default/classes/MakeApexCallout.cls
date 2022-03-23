public class MakeApexCallout
{
 public class Dcase {
  @InvocableVariable(label='transaction_id')
  public String transaction_id;
  @InvocableVariable(label='clients_ucrid')
  public String clients_ucrid;
  @InvocableVariable(label='clients_gender')
  public String clients_gender;
  @InvocableVariable(label='clients_title')
  public String clients_title;
  @InvocableVariable(label='clients_company')
  public String clients_company;
  @InvocableVariable(label='clients_firstname')
  public String clients_firstname;
  @InvocableVariable(label='clients_secondname')
  public String clients_secondname;
  @InvocableVariable(label='clients_lastname')
  public String clients_lastname;
  @InvocableVariable(label='clients_birthyear')
  public String clients_birthyear;
  @InvocableVariable(label='clients_nationality')
  public String clients_nationality;
  @InvocableVariable(label='clients_language')
  public String clients_language;
  @InvocableVariable(label='clients_ucr_creationdate')
  public String clients_ucr_creationdate;
  @InvocableVariable(label='clients_ucr_lastupdatedate')
  public String clients_ucr_lastupdatedate;
  @InvocableVariable(label='clients_local_or_tourist')
  public String clients_local_or_tourist;
  @InvocableVariable(label='clients_client_type')
  public String clients_client_type;
  @InvocableVariable(label='source')
  public String source;
  @InvocableVariable(label='source_client_id')
  public String source_client_id;
  @InvocableVariable(label='source_creation_date')
  public String source_creation_date;
  @InvocableVariable(label='source_last_update_date')
  public String source_last_update_date;
  @InvocableVariable(label='clients_city')
  public String clients_city;
  @InvocableVariable(label='clients_country')
  public String clients_country;
  @InvocableVariable(label='clients_email')
  public String clients_email;
  @InvocableVariable(label='clients_phone')
  public String clients_phone;
  @InvocableVariable(label='transaction_number')
  public String transaction_number;
  @InvocableVariable(label='transaction_source_id')
  public String transaction_source_id;
  @InvocableVariable(label='transaction_date')
  public String transaction_date;
  @InvocableVariable(label='transaction_channel')
  public String transaction_channel;
  @InvocableVariable(label='transaction_store_id')
  public String transaction_store_id;
  @InvocableVariable(label='transaction_currency')
  public String transaction_currency;
  @InvocableVariable(label='transaction_excl_tax_amount')
  public String transaction_excl_tax_amount;
  @InvocableVariable(label='transaction_incl_tax_amount')
  public String transaction_incl_tax_amount;
  @InvocableVariable(label='transaction_global_discount_amount')
  public String transaction_global_discount_amount;
  @InvocableVariable(label='transaction_tax_refund')
  public String transaction_tax_refund;
  @InvocableVariable(label='clients_light_current_cluster')
  public String clients_light_current_cluster;
  @InvocableVariable(label='clients_light_previous_cluster')
  public String clients_light_previous_cluster;
  @InvocableVariable(label='clients_vip')
  public String clients_vip;
  @InvocableVariable(label='staff_last_name')
  public String staff_last_name;
  @InvocableVariable(label='staff_first_name')
  public String staff_first_name;
  @InvocableVariable(label='staff_email')
  public String staff_email;
  @InvocableVariable(label='store_label')
  public String store_label;
  @InvocableVariable(label='store_code')
  public String store_code;
  @InvocableVariable(label='survey_id')
  public String survey_id;
  @InvocableVariable(label='template_id')
  public String template_id;
  @InvocableVariable(label='email_client_dear')
  public String email_client_dear;
  @InvocableVariable(label='email_client_title')
  public String email_client_title;
  @InvocableVariable(label='store_region')
  public String store_region;
  @InvocableVariable(label='store_country')
  public String store_country;

 }

  private static String emptiFy(String str) {
    return (str != null) ? str : '';
  }

 @InvocableMethod
 public static void invokeapexcallout(list<Dcase> cases) {
   Dcase dcase = cases[0];
   String segments = '"salesforce_transaction_id":"' + emptiFy(dcase.transaction_id) + '",' +
                     '"clients_ucrid":"' + emptiFy(dcase.clients_ucrid) + '",' +
                     '"clients_gender":"' + emptiFy(dcase.clients_gender) + '",' +
                     '"clients_title":"' + emptiFy(dcase.clients_title) + '",' +
                     '"clients_company":"' + emptiFy(dcase.clients_company) + '",' +
                     '"clients_firstname":"' + emptiFy(dcase.clients_firstname) + '",' +
                     '"clients_secondname":"' + emptiFy(dcase.clients_secondname) + '",' +
                     '"clients_lastname":"' + emptiFy(dcase.clients_lastname) + '",' +
                     '"clients_birthyear":"' + emptiFy(dcase.clients_birthyear) + '",' +
                     '"clients_nationality":"' + emptiFy(dcase.clients_nationality) + '",' +
                     '"clients_language":"' + emptiFy(dcase.clients_language) + '",' +
                     '"language":"' + emptiFy(dcase.clients_language) + '",' +
                     '"clients_ucr_creationdate":"' + emptiFy(dcase.clients_ucr_creationdate) + '",' +
                     '"clients_ucr_lastupdatedate":"' + emptiFy(dcase.clients_ucr_lastupdatedate) + '",' +
                     '"clients_local_or_tourist":"' + emptiFy(dcase.clients_local_or_tourist) + '",' +
                     '"clients_client_type":"' + emptiFy(dcase.clients_client_type) + '",' +
                     '"source":"' + emptiFy(dcase.source) + '",' +
                     '"source_client_id":"' + emptiFy(dcase.source_client_id) + '",' +
                     '"source_creation_date":"' + emptiFy(dcase.source_creation_date) + '",' +
                     '"source_last_update_date":"' + emptiFy(dcase.source_last_update_date) + '",' +
                     '"clients_city":"' + emptiFy(dcase.clients_city) + '",' +
                     '"clients_country":"' + emptiFy(dcase.clients_country) + '",' +
                     '"clients_email":"' + emptiFy(dcase.clients_email) + '",' +
                     '"clients_phone":"' + emptiFy(dcase.clients_phone) + '",' +
                     '"transaction_number":"' + emptiFy(dcase.transaction_number) + '",' +
                     '"transaction_source_id":"' + emptiFy(dcase.transaction_source_id) + '",' +
                     '"transaction_date":"' + emptiFy(dcase.transaction_date) + '",' +
                     '"transaction_channel":"' + emptiFy(dcase.transaction_channel) + '",' +
                     '"transaction_store_id":"' + emptiFy(dcase.transaction_store_id) + '",' +
                     '"transaction_currency":"' + emptiFy(dcase.transaction_currency) + '",' +
                     '"transaction_excl_tax_amount":"' + emptiFy(dcase.transaction_excl_tax_amount) + '",' +
                     '"transaction_incl_tax_amount":"' + emptiFy(dcase.transaction_incl_tax_amount) + '",' +
                     '"transaction_global_discount_amount":"' + emptiFy(dcase.transaction_global_discount_amount) + '",' +
                     '"transaction_tax_refund":"' + emptiFy(dcase.transaction_tax_refund) + '",' +
                     '"transaction_number":"' + emptiFy(dcase.transaction_number) + '",' +
                     '"clients_light_current_cluster":"' + emptiFy(dcase.clients_light_current_cluster) + '",' +
                     '"clients_light_previous_cluster":"' + emptiFy(dcase.clients_light_previous_cluster) + '",' +
                     '"clients_vip":"' + emptiFy(dcase.clients_vip) + '",' +
                     '"staff_first_name":"' + emptiFy(dcase.staff_first_name) + '",' +
                     '"staff_last_name":"' + emptiFy(dcase.staff_last_name) + '",' +
                     '"staff_email":"' + emptiFy(dcase.staff_email) + '",' +
                     '"store_label":"' + emptiFy(dcase.store_label) + '",' +
                     '"store_code":"' + emptiFy(dcase.store_code) + '",' +
                     '"email_client_dear":"' + emptiFy(dcase.email_client_dear) + '",' +
                     '"email_client_title":"' + emptiFy(dcase.email_client_title) + '",' +
                     '"store_region":"' + emptiFy(dcase.store_region) + '",' +
                     '"store_country":"' + emptiFy(dcase.store_country) + '"';
   WebServicescallout.sendSurvey(dcase.clients_email, dcase.survey_id, dcase.template_id, segments);
 }
}