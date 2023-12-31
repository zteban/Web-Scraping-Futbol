USE [proyectoFinal]
GO
/****** Object:  StoredProcedure [dbo].[spImportDisparos]    Script Date: 23/11/2023 11:48:24 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ---------------------------
<Descripción>
Transformacion y carga de los datos del crudo Disparos:\\TPCCP-DB20\Dropbox\New Economy\Enigma\CO\Disparos.

<Execute>

EXEC [dbo].[spImportDisparos];

*/

ALTER PROCEDURE [dbo].[spImportDisparos]
AS
SET NOCOUNT	ON;
	IF OBJECT_ID('tempdb..#tmpBuscaFiles') IS NOT NULL DROP TABLE #tmpBuscaFiles;
	CREATE TABLE #tmpBuscaFiles
    (
		 [archivo]  varchar(255)
		,[depth]    int
		,[filetype] int
	)

	DECLARE @ruta VARCHAR(4000) = 'C:\Users\User\Desktop\ProyectoWebScrapping\Disparos2\'
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


	IF OBJECT_ID('tempdb..#tmpDisparos') IS NOT NULL DROP TABLE #tmpDisparos;
	CREATE TABLE #tmpDisparos
	(	 
		 [Jugador]				VARCHAR(300)
		,[Pais]					VARCHAR(300)
		,[Posc]					VARCHAR(300)
		,[Equipo]				VARCHAR(300)
		,[Edad]					VARCHAR(300)
		,[Nacimiento]			VARCHAR(300)
		,[90s]					VARCHAR(300)
		,[Gls]					VARCHAR(300)
		,[Dis]					VARCHAR(300)
		,[DaP]					VARCHAR(300)
		,[PorcentajeDeTT]		VARCHAR(300)
		,[T90]					VARCHAR(300)
		,[TalArc90]				VARCHAR(300)
		,[GT]					VARCHAR(300)
		,[GTalArc]				VARCHAR(300)
		,[Dist]					VARCHAR(300)
		,[FK]					VARCHAR(300)
		,[TP]					VARCHAR(300)
		,[TPint]				VARCHAR(300)
		,[xG]					VARCHAR(300)
		,[npxG]					VARCHAR(300)
		,[npxGSh]				VARCHAR(300)
		,[GxG]					VARCHAR(300)
		,[npGxG]				VARCHAR(300)
		,[Partidos]				VARCHAR(300)
	);

	WHILE @i > 0 AND (SELECT TOP 1 archivo FROM #tmpBuscaFiles) <> 'File Not Found'
	BEGIN
		BEGIN TRY	
			SET @file = (SELECT archivo FROM #tmpBuscaFiles WHERE a = @i);
			SET @fnr = @Ruta + @file;
			PRINT @fnr


			IF OBJECT_ID('tempdb..#tmpDisparosQA') IS NOT NULL DROP TABLE #tmpDisparosQA;
			CREATE TABLE #tmpDisparosQA (
				 [Jugador]				VARCHAR(200)
				,[Pais]					VARCHAR(50)
				,[Posc]					VARCHAR(40)
				,[Equipo]				VARCHAR(90)
				,[Edad]					INT
				,[Nacimiento]			INT
				,[90s]					DECIMAL(5,2)
				,[Gls]					INT
				,[Dis]					INT
				,[DaP]					INT
				,[PorcentajeDeTT]		DECIMAL(5,2)
				,[T90]					DECIMAL(5,2)
				,[TalArc90]				DECIMAL(5,2)
				,[GT]					DECIMAL(5,2)
				,[GTalArc]				DECIMAL(5,2)
				,[Dist]					DECIMAL(5,2)
				,[FK]					INT
				,[TP]					INT
				,[TPint]				INT
				,[xG]					DECIMAL(5,2)
				,[npxG]					DECIMAL(5,2)
				,[npxGSh]				DECIMAL(5,2)
				,[GxG]					DECIMAL(5,2)
				,[npGxG]				DECIMAL(5,2)
				,[ImportDate]			DATETIME
				,[Temporada]			VARCHAR(30)
				,[Liga]					VARCHAR(30)
			);


			EXEC('BULK INSERT #tmpDisparos FROM ''' + @fnr + ''' WITH (FIELDTERMINATOR = '','',ROWTERMINATOR = ''0X0A'',FORMAT = ''CSV'',CODEPAGE = ''65001'',BATCHSIZE=1000)');

			---- Limpieza de Datos ------------------------

			DELETE FROM #tmpDisparos WHERE ([Jugador] LIKE '%Jugador%' AND [Equipo] LIKE '%Equipo%') OR ([Jugador] IS NULL AND [Equipo] IS NULL);


			INSERT INTO #tmpDisparosQA
			SELECT [Jugador]			
				  ,[Pais]				
				  ,[Posc]				
				  ,[Equipo]				
				  ,YEAR(GETDATE())-CAST([Nacimiento] AS INT)					
				  ,CAST([Nacimiento]                 AS INT)
				  ,CAST([90s]			             AS DECIMAL(5,2))
				  ,CAST([Gls]			             AS INT)
				  ,CAST([Dis]			             AS INT)
				  ,CAST([DaP]			             AS INT)
				  ,CAST([PorcentajeDeTT]             AS DECIMAL(5,2))
				  ,CAST([T90]			             AS DECIMAL(5,2))
				  ,CAST([TalArc90]		             AS DECIMAL(5,2))
				  ,CAST([GT]			             AS DECIMAL(5,2))
				  ,CAST([GTalArc]		             AS DECIMAL(5,2))
				  ,CAST([Dist]			             AS DECIMAL(5,2))
				  ,CAST([FK]			             AS INT)
				  ,CAST([TP]			             AS INT)
				  ,CAST([TPint]			             AS INT)
				  ,CAST([xG]			             AS DECIMAL(5,2))
				  ,CAST([npxG]			             AS DECIMAL(5,2))
				  ,CAST([npxGSh]		             AS DECIMAL(5,2))
				  ,CAST([GxG]			             AS DECIMAL(5,2))
				  ,CAST([npGxG]			             AS DECIMAL(5,2))
				  ,GETDATE()								  AS [ImportDate]
				  ,RIGHT(REPLACE(@file,'.csv','') ,9)         AS [Temporada]	
				  ,SUBSTRING(@file,1,CHARINDEX('_',@file)-1)  AS [Liga]						
			FROM #tmpDisparos;	
			

			--------------------------------------- Llave Borrado -------------

			--WITH CTE AS (SELECT ROW_NUMBER() OVER (PARTITION BY [Equipo] order by [Equipo] DESC) Rk  FROM #tmpDisparosQA)
			--DELETE FROM CTE WHERE Rk > 1;

			

			DELETE A FROM  tbDisparos A
			INNER JOIN #tmpDisparosQA B ON A.[Temporada] = B.[Temporada] AND A.[Liga] = B.[Liga] ;



			INSERT INTO [dbo].[tbDisparos]
			(					 
				 [Jugador]				
				,[Pais]					
				,[Posc]					
				,[Equipo]				
				,[Edad]					
				,[Nacimiento]			
				,[90s]					
				,[Gls]					
				,[Dis]					
				,[DaP]					
				,[PorcentajeDeTT]		
				,[T90]					
				,[TalArc90]				
				,[GT]					
				,[GTalArc]				
				,[Dist]					
				,[FK]					
				,[TP]					
				,[TPint]				
				,[xG]					
				,[npxG]					
				,[npxGSh]				
				,[GxG]					
				,[npGxG]				
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
				  ,[90s]					
				  ,[Gls]					
				  ,[Dis]					
				  ,[DaP]					
				  ,[PorcentajeDeTT]		
				  ,[T90]					
				  ,[TalArc90]				
				  ,[GT]					
				  ,[GTalArc]				
				  ,[Dist]					
				  ,[FK]					
				  ,[TP]					
				  ,[TPint]				
				  ,[xG]					
				  ,[npxG]					
				  ,[npxGSh]				
				  ,[GxG]					
				  ,[npGxG]				
				  ,[ImportDate]			
				  ,[Temporada]			
				  ,[Liga]			
			FROM #tmpDisparosQA;
		
		
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
		
		TRUNCATE TABLE #tmpDisparos;

		--Se disminuye el número de archivos pendientes en 1
		SET @i = @i - 1;

		--Fin del ciclo
		END
		
		IF OBJECT_ID('tempdb..#OuFiles') IS NOT NULL DROP TABLE #OuFiles;
		IF OBJECT_ID('tempdb..#tmpDisparos') IS NOT NULL DROP TABLE #tmpDisparos;
		IF OBJECT_ID('tempdb..#tmpDisparosQA') IS NOT NULL DROP TABLE #tmpDisparosQA;
	
	IF @Severity = 1
	BEGIN
		RAISERROR('Error en Bloque Try',16,1);
	END

--Fin del procedimiento almacenado


