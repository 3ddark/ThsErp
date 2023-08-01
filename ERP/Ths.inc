//helper input (ths helper) içinde ufrmBaseInputDB tanýmlý bunun derlemede sorun olmamasý için bu þekilde kullanýyoruz.
{$DEFINE THSERP}

//eski programdan burada güncelleme ile data aktarmak için kullanýyoruz.
{$DEFINE MIGRATE}

//Geliþtirici demo bilgilerini kullanmak istediðinde bu direktifi kullanacak.
//The developer will use this directive when he wants to use the demo data.
//{$DEFINE DUMMY_VALUE}

//Geliþtiricinin Select, Insert, Update, Delete iþlemlerini hangi metod ile gerçekleþtireceðini burada belirliyoruz.
//Here, we determine which method the developer will perform Select, Insert, Update, Delete operations.
{$DEFINE CRUD_MODE_PURE_SQL}  //CRUD_MODE_SP - CRUD_MODE_PURE_SQL
