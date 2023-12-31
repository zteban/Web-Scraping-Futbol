USE [proyectoFinal]
GO
/****** Object:  StoredProcedure [dbo].[spImportPases]    Script Date: 23/11/2023 11:48:27 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/* ---------------------------
<Descripción>
Transformacion y carga de los datos del crudo tbPases:\\TPCCP-DB20\Dropbox\New Economy\Enigma\CO\tbPases.

<Execute>

EXEC [dbo].[spImportPases];

*/

ALTER PROCEDURE [dbo].[spImportPases]
AS
SET NOCOUNT	ON;
	IF OBJECT_ID('tempdb..#tmpBuscaFiles') IS NOT NULL DROP TABLE #tmpBuscaFiles;
	CREATE TABLE #tmpBuscaFiles
    (
		 [archivo]  varchar(255)
		,[depth]    int
		,[filetype] int
	)

	DECLARE @ruta VARCHAR(4000) = 'C:\Users\User\Desktop\ProyectoWebScrapping\Pases\'
	DECLARE @return_value INT=0;

	INSERT INTO #tmpBuscaFiles
		EXEC master.sys.xp_dirtree @ruta,0,1;

	DELETE FROM #tmpBuscaFiles WHERE depth !=1;
	DELETE FROM #tmpBuscaFiles WHERE archivo NOT LIKE '%.csv%';
	ALTER TABLE #tmpBuscaFiles ADD a INT IDENTITY(1,1);

	DECLARE @i INT = (SELECT COUNT(*) FROM #tmpBuscaFiles WHERE archivo IS NOT NULL); 
	DECLARE @fnr VARCHAR(350);
	DECLARE @file VARCHAR(350);
	DECLARE @error int = 0;
	DECLARE @severity int=0;


	IF OBJECT_ID('tempdb..#tmptbPases') IS NOT NULL DROP TABLE #tmptbPases;
	CREATE TABLE #tmptbPases
	(	 
		 [Jugador]				        VARCHAR(300)
		,[Pais]					        VARCHAR(300)
		,[Posc]					        VARCHAR(300)
		,[Equipo]				        VARCHAR(300)
		,[Edad]					        VARCHAR(300)
		,[Nacimiento]			        VARCHAR(300)
		,[PartidosJugados]				VARCHAR(300)
		,[PasesCompletados]				VARCHAR(300)
		,[PasesIntentados]				VARCHAR(300)
		,[%PasesCompletado]				VARCHAR(300)
		,[DistanciaPases]				VARCHAR(300)
		,[DistanciaPasesProgresiva]		VARCHAR(300)
		,[CortosPasesCompletados]		VARCHAR(300)
		,[CortosPasesIntentados]		VARCHAR(300)
		,[Cortos%PasesCompletados]		VARCHAR(300)
		,[MediosPasesCompletados]		VARCHAR(300)
		,[MediosPasesIntentados]		VARCHAR(300)
		,[Medios%PasesCompletados]		VARCHAR(300)
		,[LargosPasesCompletados]		VARCHAR(300)
		,[LargosPasesIntentados]		VARCHAR(300)
		,[Largos%PasesCompletados]		VARCHAR(300)
		,[Asistencias]					VARCHAR(300)
		,[xAG]							VARCHAR(300)
		,[xA]							VARCHAR(300)
		,[A-xAG]						VARCHAR(300)
		,[PC]							VARCHAR(300)
		,[1-mar]						VARCHAR(300)
		,[PPA]							VARCHAR(300)
		,[CrAP]							VARCHAR(300)
		,[PrgP]							VARCHAR(300)
		,[Partidos]						VARCHAR(300)
	);									

	WHILE @i > 0 AND (SELECT TOP 1 archivo FROM #tmpBuscaFiles) <> 'File Not Found'
	BEGIN
		BEGIN TRY	
			SET @file = (SELECT archivo FROM #tmpBuscaFiles WHERE a = @i);
			SET @fnr = @Ruta + @file;
			PRINT @fnr


			IF OBJECT_ID('tempdb..#tmptbPasesQA') IS NOT NULL DROP TABLE #tmptbPasesQA;
			CREATE TABLE #tmptbPasesQA (
				 [Jugador]				            VARCHAR(200)
				,[Pais]					            VARCHAR(50)
				,[Posc]					            VARCHAR(40)
				,[Equipo]				            VARCHAR(90)
				,[Edad]					            INT
				,[Nacimiento]			            INT
				,[PartidosJugados]					DECIMAL(5,2)
				,[PasesCompletados]				    INT
				,[PasesIntentados]				    INT
				,[%PasesCompletado]				    DECIMAL(5,2)
				,[DistanciaPases]				    INT
				,[DistanciaPasesProgresiva]		    INT
				,[CortosPasesCompletados]		    INT
				,[CortosPasesIntentados]		    INT
				,[Cortos%PasesCompletados]		    DECIMAL(5,2)
				,[MediosPasesCompletados]		    INT
				,[MediosPasesIntentados]		    INT
				,[Medios%PasesCompletados]		    DECIMAL(5,2)
				,[LargosPasesCompletados]		    INT
				,[LargosPasesIntentados]		    INT
				,[Largos%PasesCompletados]		    DECIMAL(5,2)
				,[Asistencias]					    INT
				,[xAG]							    DECIMAL(5,2)
				,[xA]							    DECIMAL(5,2)
				,[A-xAG]						    DECIMAL(5,2)
				,[PC]							    INT
				,[1-mar]						    INT
				,[PPA]							    INT
				,[CrAP]							    INT
				,[PrgP]							    INT
				,[ImportDate]			            DATETIME
				,[Temporada]			            VARCHAR(30)
				,[Liga]					            VARCHAR(30)
			);


			EXEC('BULK INSERT #tmptbPases FROM ''' + @fnr + ''' WITH (FIELDTERMINATOR = '','',ROWTERMINATOR = ''0X0A'',FORMAT = ''CSV'',CODEPAGE = ''65001'',BATCHSIZE=1000)');

			---- Limpieza de Datos ------------------------

			DELETE FROM #tmptbPases WHERE ([Jugador] LIKE '%Jugador%' AND [Equipo] LIKE '%Equipo%') OR ([Jugador] IS NULL AND [Equipo] IS NULL);


			INSERT INTO #tmptbPasesQA
			SELECT [Jugador]			
				  ,[Pais]				
				  ,[Posc]				
				  ,[Equipo]				
				  ,YEAR(GETDATE())-CAST([Nacimiento] AS INT)					
				  ,CAST([Nacimiento]                 AS INT)
				  ,CAST([PartidosJugados]			 AS DECIMAL(5,2))
				  ,CAST([PasesCompletados]			 AS INT			)
				  ,CAST([PasesIntentados]			 AS INT			)
				  ,CAST([%PasesCompletado]			 AS DECIMAL(5,2))
				  ,CAST([DistanciaPases]			 AS INT			)
				  ,CAST([DistanciaPasesProgresiva]	 AS INT			)
				  ,CAST([CortosPasesCompletados]	 AS INT			)
				  ,CAST([CortosPasesIntentados]		 AS INT			)
				  ,CAST([Cortos%PasesCompletados]	 AS DECIMAL(5,2))
				  ,CAST([MediosPasesCompletados]	 AS INT			)
				  ,CAST([MediosPasesIntentados]		 AS INT			)
				  ,CAST([Medios%PasesCompletados]	 AS DECIMAL(5,2))
				  ,CAST([LargosPasesCompletados]	 AS INT			)
				  ,CAST([LargosPasesIntentados]		 AS INT			)
				  ,CAST([Largos%PasesCompletados]	 AS DECIMAL(5,2))
				  ,CAST([Asistencias]				 AS INT			)
				  ,CAST([xAG]						 AS DECIMAL(5,2))
				  ,CAST([xA]						 AS DECIMAL(5,2))
				  ,CAST([A-xAG]						 AS DECIMAL(5,2))
				  ,CAST([PC]						 AS INT			)
				  ,CAST([1-mar]						 AS INT			)
				  ,CAST([PPA]						 AS INT			)
				  ,CAST([CrAP]						 AS INT			)
				  ,CAST([PrgP]						 AS INT			)
				  ,GETDATE()								  AS [ImportDate]
				  ,RIGHT(REPLACE(@file,'.csv','') ,9)         AS [Temporada]	
				  ,SUBSTRING(@file,1,CHARINDEX('_',@file)-1)  AS [Liga]						
			FROM #tmptbPases;	
			

			--------------------------------------- Llave Borrado -------------

			--WITH CTE AS (SELECT ROW_NUMBER() OVER (PARTITION BY [Equipo] order by [Equipo] DESC) Rk  FROM #tmptbPasesQA)
			--DELETE FROM CTE WHERE Rk > 1;

			

			DELETE A FROM  tbPases A
			INNER JOIN #tmptbPasesQA B ON A.[Temporada] = B.[Temporada] AND A.[Liga] = B.[Liga] ;



			INSERT INTO [dbo].[tbPases]
			(					 
				 [Jugador]				            
				,[Pais]					            
				,[Posc]					            
				,[Equipo]				            
				,[Edad]					            
				,[Nacimiento]			            
				,[PartidosJugados]					
				,[PasesCompletados]				    
				,[PasesIntentados]				    
				,[%PasesCompletado]				    
				,[DistanciaPases]				    
				,[DistanciaPasesProgresiva]		    
				,[CortosPasesCompletados]		    
				,[CortosPasesIntentados]		    
				,[Cortos%PasesCompletados]		    
				,[MediosPasesCompletados]		    
				,[MediosPasesIntentados]		    
				,[Medios%PasesCompletados]		    
				,[LargosPasesCompletados]		    
				,[LargosPasesIntentados]		    
				,[Largos%PasesCompletados]		    
				,[Asistencias]					    
				,[xAG]							    
				,[xA]							    
				,[A-xAG]						    
				,[PC]							    
				,[1-mar]						    
				,[PPA]							    
				,[CrAP]							    
				,[PrgP]							    
				,[ImportDate]			            
				,[Temporada]			            
				,[Liga]					            
			)
			SELECT [Jugador]				            
				  ,[Pais]					            
				  ,[Posc]					            
				  ,[Equipo]				            
				  ,[Edad]					            
				  ,[Nacimiento]			            
				  ,[PartidosJugados]					
				  ,[PasesCompletados]				    
				  ,[PasesIntentados]				    
				  ,[%PasesCompletado]				    
				  ,[DistanciaPases]				    
				  ,[DistanciaPasesProgresiva]		    
				  ,[CortosPasesCompletados]		    
				  ,[CortosPasesIntentados]		    
				  ,[Cortos%PasesCompletados]		    
				  ,[MediosPasesCompletados]		    
				  ,[MediosPasesIntentados]		    
				  ,[Medios%PasesCompletados]		    
				  ,[LargosPasesCompletados]		    
				  ,[LargosPasesIntentados]		    
				  ,[Largos%PasesCompletados]		    
				  ,[Asistencias]					    
				  ,[xAG]							    
				  ,[xA]							    
				  ,[A-xAG]						    
				  ,[PC]							    
				  ,[1-mar]						    
				  ,[PPA]							    
				  ,[CrAP]							    
				  ,[PrgP]							    
				  ,[ImportDate]			            
				  ,[Temporada]			            
				  ,[Liga]	
			FROM #tmptbPasesQA;
		
		
		END TRY

		BEGIN CATCH
			SET @error = 1;
			SET @severity = 0;
			PRINT ERROR_MESSAGE();
		END CATCH

		/*=======================Manejo de Errores=========================*/
		DECLARE @cmd NVARCHAR(4000);

		IF @error = 0 
		BEGIN 
			
			SET @cmd = 'MOVE "' + @fnr + '" "' + @Ruta + '\Procesado\'+ @file+ '"';
			EXEC xp_cmdshell @cmd;
			print 'procesado';
		END 

		ELSE 
		BEGIN 
			SET @cmd = 'MOVE "' + @fnr + '" "' + @Ruta + '\Error\'+ @file+ '"';
			EXEC xp_cmdshell @cmd;
			print 'procesado';
		END;	
		
		TRUNCATE TABLE #tmptbPases;

		--Se disminuye el número de archivos pendientes en 1
		SET @i = @i - 1;

		--Fin del ciclo
		END
		
		IF OBJECT_ID('tempdb..#OuFiles') IS NOT NULL DROP TABLE #OuFiles;
		IF OBJECT_ID('tempdb..#tmptbPases') IS NOT NULL DROP TABLE #tmptbPases;
		IF OBJECT_ID('tempdb..#tmptbPasesQA') IS NOT NULL DROP TABLE #tmptbPasesQA;
	
	IF @Severity = 1
	BEGIN
		RAISERROR('Error en Bloque Try',16,1);
	END

--Fin del procedimiento almacenado


