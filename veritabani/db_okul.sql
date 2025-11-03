/*
KURULUM DETAYLARI
- İmleç bu sayfada iken "Execute" butonu veya F5 tuşu ile sayfadaki sorgular işletilir.
- Sorgular işletildikten sonra "Db_okul" veritabanı, tabloları ve verileri oluşturuldu." mesajı çıktı olarak görülmelidir.
- Hata alınması durumunda sık karşılaşılan durum veritabanının ilgili sunucuda var olması ve seçili olmasından kaynaklı silme işlemenin gerçekleştirilememesidir.
- CTRL + U seçeneği ile ya da "Execute" butonunun sol tarafında aktif/seçili durumda olan veritabanı tüm çalışma sayfalarında "Db_okul" dışında bir seçeneğe ayarlanarak sayfa tekrar çalıştırılmalıdır.



 -------------------------------
|Db_okul veritabanı  - 2023    |
|--Update 03.11.25             |
 -------------------------------
_________________________
|Bulunan Tablolar:      |
|-----------------------|
|1- ogrenci             |
|2- ogrenci_detay       |
|3- ogretmen            |
|4- bolum               |
|5- ders                |
_________________________





*/
BEGIN TRY
SET NOCOUNT ON;
USE master;

DECLARE @SQL nvarchar(1000);
IF EXISTS (SELECT TOP 1 * FROM sys.databases WHERE [name] = N'Db_okul')
BEGIN
    SET @SQL = N'ALTER DATABASE Db_okul SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
                 DROP DATABASE Db_okul;';
    EXEC (@SQL);
END;


DECLARE @device_directory NVARCHAR(520)
SELECT @device_directory = SUBSTRING(filename, 1, CHARINDEX(N'master.mdf', LOWER(filename)) - 1)
FROM master.dbo.sysaltfiles WHERE dbid = 1 AND fileid = 1


EXECUTE (N'CREATE DATABASE Db_okul
  ON PRIMARY (NAME = N''Db_okul'', FILENAME = N''' + @device_directory + N'dokul.mdf'')
  LOG ON (NAME = N''dokul_log'',  FILENAME = N''' + @device_directory + N'dokul.ldf'')')

DECLARE @SQL_Setup nvarchar(MAX);
SET @SQL_Setup = N'
USE "Db_okul"; 

set quoted_identifier on;
SET DATEFORMAT mdy;

/*TABLE*/
CREATE TABLE "ogrenci" (
	"id" "int" IDENTITY (1, 1) NOT NULL ,
	"tc_kimlik" nvarchar (50) NOT NULL,
	"ad" nvarchar (50) NOT NULL ,
	"soyad" nvarchar (50) NOT NULL ,
	"dogum_yeri" nvarchar (50) NOT NULL ,
	"dogum_tarihi" date,
	CONSTRAINT "PK_ogrenci" PRIMARY KEY  CLUSTERED("id")
	);
CREATE TABLE "bolum" (
"id" "int" IDENTITY (1, 1) NOT NULL,
"bolum_adi" NVARCHAR(100) NOT NULL,
CONSTRAINT "PK_bolum" PRIMARY KEY  CLUSTERED("id"),
);
CREATE TABLE "ogretmen" (
"id" "int" IDENTITY (1, 1) NOT NULL ,
"ad" NVARCHAR(20) NOT NULL,
"soyad" NVARCHAR(20) NOT NULL,
"bolum_id" INT,
"brans" NVARCHAR(40),
"dogum_yeri" NVARCHAR(40),
CONSTRAINT "PK_ogretmen" PRIMARY KEY  CLUSTERED("id"),
CONSTRAINT "FK_bolumO" FOREIGN KEY("bolum_id") REFERENCES bolum(id) ON DELETE SET NULL ON UPDATE NO ACTION,
);

CREATE TABLE ders (
"id" "int" IDENTITY (1, 1) NOT NULL ,
"ders_adi" NVARCHAR(50) NOT NULL,
"brans" NVARCHAR(40),
CONSTRAINT "PK_ders" PRIMARY KEY  CLUSTERED("id"),
);

CREATE TABLE ders_ogretmen (
"id" "int" IDENTITY (1, 1) NOT NULL ,
"ders_id" INT NOT NULL,
"ogretmen_id" INT NOT NULL,
CONSTRAINT "PK_ders_ogretmen" PRIMARY KEY  CLUSTERED("id"),
CONSTRAINT "FK_ders" FOREIGN KEY("ders_id") REFERENCES ders(id) ON DELETE CASCADE ON UPDATE NO ACTION,
CONSTRAINT "FK_ogretmenD" FOREIGN KEY("ogretmen_id") REFERENCES ogretmen(id) ON DELETE CASCADE ON UPDATE NO ACTION,
);

CREATE TABLE ders_bolum (
"id" "int" IDENTITY (1, 1) NOT NULL ,
"bolum_id" INT NOT NULL,
"ders_id" INT NOT NULL,
CONSTRAINT "PK_ders_bolum" PRIMARY KEY  CLUSTERED("id"),
CONSTRAINT "FK_bolumD" FOREIGN KEY("bolum_id") REFERENCES bolum(id) ON DELETE CASCADE ON UPDATE NO ACTION,
CONSTRAINT "FK_dersB" FOREIGN KEY("ders_id") REFERENCES ders(id) ON DELETE CASCADE ON UPDATE NO ACTION,
);

CREATE TABLE "ogrenci_detay" (
	"id" "int" IDENTITY (1, 1) NOT NULL ,
	"ogrenci_id" INT NOT NULL,
	"danisman_id" INT,
	"bolum_id" INT,
	"ortalama" INT,
	"telefon" NVARCHAR(30),
	"adres" NVARCHAR(MAX),
	CONSTRAINT "PK_ogrenci_detay" PRIMARY KEY  CLUSTERED ("id"),
	CONSTRAINT "FK_ogrenci" FOREIGN KEY("ogrenci_id") REFERENCES ogrenci(id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT "FK_danisman" FOREIGN KEY("danisman_id") REFERENCES ogretmen(id) ON DELETE SET NULL ON UPDATE NO ACTION,
	CONSTRAINT "FK_bolum" FOREIGN KEY("bolum_id") REFERENCES bolum(id) ON DELETE SET NULL ON UPDATE NO ACTION,
	);
/*TABLE*/

/*DATA*/

INSERT bolum VALUES
(N''Bilgisayar programcılığı''),
(N''Web Tasarımı ve Kodlama''),
(N''İnternet ve Ağ Teknolojileri''),
(N''Muhasebe'');

INSERT ogretmen VALUES
(N''Abdulmelik'',N''Derinkök'',NULL,N''Eğitim Bilimleri'',N''Malatya''),
(N''Ahmet'',N''Mutlu'',NULL,N''Bilgisayar'',N''İzmir''),
(N''Erhan'',N''Kara'',1,N''Bilgisayar'',N''Bursa''),
(N''Yusuf'',N''Aydın'',2,N''Web Tasarım'',N''Sakarya''),
(N''Ali'',N''Türk'',2,N''Web Tasarım'',N''Edirne'');

INSERT  ogrenci VALUES 
(N''11111111110'', N''Ahmet'',N''Ünlü'',N''Malatya'',''1997-05-18''),
(N''22222222220'', N''Mehmet'',N''Yılmaz'',N''İstanbul'',''1999-09-17''),
(N''33333333330'', N''Ayşe'',N''Demir'',N''Hatay'',''1997-08-05''),
(N''44444444440'', N''Hacer'',N''Çakır'',N''Siirt'',''1997-03-12''),
(N''55555555550'', N''Hamdi'',N''Kaya'',N''Gaziantep'',''1996-01-25''),
(N''66666666660'', N''Yasemin'',N''Çelik'',N''Rize'',''1999-05-30''),
(N''77777777770'', N''Zeynep'',N''Aydın'',N''Bilecik'',''1995-02-06'');

INSERT  ogrenci_detay(ogrenci_id,danisman_id,bolum_id,ortalama,telefon,adres) VALUES 
(1,1, 1,65,N''05541234567'',N''Merkez - Bilecik''),
(2,3, 3,73,N''05351234567'',N''Merkez - Bilecik''),
(3,4, 2,38,N''05451234567'',N''Merkez - Bilecik''),
(4,5, NULL,92,N''05051234567'',N''Merkez - Bilecik''),
(5,2, 1,79,N''05301234567'',N''Merkez - Bilecik''),
(6,1, 2,48,N''05321234567'',N''Pazayeri - Bilecik''),
(7,5, 3,55,N''05441234567'',N''Pazayeri - Bilecik'');

INSERT  ogrenci_detay VALUES 
(3,2, NULL,70,N''05061234567'',N''Pazayeri - Bilecik''),
(5,3, 1,77,N''05381234567'',N''Pazayeri - Bilecik'');

INSERT  ders VALUES 
(N''Veritabanı ve Yönetim Sistemleri'', N''Bilgisayar''),
(N''Web Tasarımın Temelleri'', N''Bilgisayar'');
INSERT  ders(ders_adi) VALUES 
(N''Proje Yönetimi'');
INSERT  ders VALUES 
(N''Temel Elektronik'', N''Elektrik''),
(N''Matematik'', N''Kültür''),
(N''Tarih'', N''Kültür''),
(N''Türk Dili'', N''Kültür''),
(N''Ağ Cihazları'', N''Ağ Teknolojileri''),
(N''Kablosuz Ağ Cihazları'', N''Ağ Teknolojileri''),
(N''Mobil Uygulama Geliştirme'', N''Web''),
(N''İleri Web Programlama'', N''Bilgisayar''),
(N''Grafik ve Animasyon'', N''Web''),
(N''Kullanıcı Arabirimi Tasarımı'', N''Web'');

INSERT ders_bolum VALUES
(1,1),
(2,1),
(3,1),
(1,2),
(2,2),
(1,5),
(3,5),
(1,6),
(2,6),
(3,6),
(1,7),
(2,7),
(3,7),
(3,8),
(3,9),
(2,10),
(1,11),
(2,12),
(1,13);

INSERT ders_ogretmen VALUES
(1,1),
(1,2),
(2,3),
(5,5),
(5,3),
(4,1),
(13,2),
(11,2),
(10,1);
/*DATA*/
';


EXEC sp_executesql @SQL_Setup;

print('"Db_okul" veritabanı, tabloları ve verileri oluşturuldu.')
END TRY
BEGIN CATCH
    PRINT('!!! HATA OLUŞTU !!!');
    
    SELECT 
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_STATE() AS ErrorState,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_PROCEDURE() AS ErrorProcedure,
        ERROR_LINE() AS ErrorLine,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH