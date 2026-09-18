//helper input (ths helper) içinde ufrmBaseInputDB tanımlı bunun derlemede sorun olmaması için bu şekilde kullanıyoruz.
{$DEFINE THSERP}

//eski programdan burada güncelleme ile data aktarmak için kullanıyoruz.
{$DEFINE MIGRATE}

//Geliştirici demo bilgilerini kullanmak istediğinde bu direktifi kullanacak.
//The developer will use this directive when he wants to use the demo data.
//{$DEFINE DUMMY_VALUE}

//Geliştiricinin Select, Insert, Update, Delete işlemlerini hangi metod ile gerçekleştireceğini burada belirliyoruz.
//Here, we determine which method the developer will perform Select, Insert, Update, Delete operations.
{$DEFINE CRUD_MODE_PURE_SQL}  //CRUD_MODE_SP - CRUD_MODE_PURE_SQL

//Debug modunda veya FULL_LOG_SQL tanımlı olduğunda çalıştırılan CRUD SQL kodlarının tamamı loglanır.
//When DEBUG mode is active or FULL_LOG_SQL is defined, all executed CRUD SQL codes are logged.
{$DEFINE FULL_LOG_SQL}