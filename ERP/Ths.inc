//helper input (ths helper) i�inde ufrmBaseInputDB tan�ml� bunun derlemede sorun olmamas� i�in bu �ekilde kullan�yoruz.
{$DEFINE THSERP}

//eski programdan burada g�ncelleme ile data aktarmak i�in kullan�yoruz.
{$DEFINE MIGRATE}

//Geli�tirici demo bilgilerini kullanmak istedi�inde bu direktifi kullanacak.
//The developer will use this directive when he wants to use the demo data.
//{$DEFINE DUMMY_VALUE}

//Geli�tiricinin Select, Insert, Update, Delete i�lemlerini hangi metod ile ger�ekle�tirece�ini burada belirliyoruz.
//Here, we determine which method the developer will perform Select, Insert, Update, Delete operations.
{$DEFINE CRUD_MODE_PURE_SQL}  //CRUD_MODE_SP - CRUD_MODE_PURE_SQL