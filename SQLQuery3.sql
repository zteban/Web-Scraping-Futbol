USE [proyectoFinal]
GO
/****** Object:  StoredProcedure [dbo].[spImportPorteros]    Script Date: 23/11/2023 11:48:28 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/* ---------------------------
<Descripción>
Transformacion y carga de los datos del crudo Disparos:\\TPCCP-DB20\Dropbox\New Economy\Enigma\CO\Disparos.

<Execute>

EXEC [dbo].[spImportPorteros];

*/

ALTER PROCEDURE [dbo].[spImportPorteros]
AS
SET NOCOUNT	ON;
	IF OBJECT_ID('tempdb..#tmpBuscaFiles') IS NOT NULL DROP TABLE #tmpBuscaFiles;
	CREATE TABLE #tmpBuscaFiles
    (
		 [archivo]  varchar(255)
		,[depth]    int
		,[filetype] int
	)

	DECLARE @ruta VARCHAR(4000) = 'C:\Users\User\Desktop\ProyectoWebScrapping\Porteros\'
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


	IF OBJECT_ID('tempdb..#tmpPorteros') IS NOT NULL DROP TABLE #tmpPorteros;
	CREATE TABLE #tmpPorteros
	(	 
		 [Jugador]				      VARCHAR(300)
		,[Pais]					      VARCHAR(300)
		,[Posc]					      VARCHAR(300)
		,[Equipo]				      VARCHAR(300)
		,[Edad]					      VARCHAR(300)
		,[Nacimiento]			      VARCHAR(300)
		,[PartidosJugados]			  VARCHAR(300)
		,[Titular]					  VARCHAR(300)
		,[Minutos]					  VARCHAR(300)
		,[PartidosJugados2]			  VARCHAR(300)
		,[GolesEnContra]			  VARCHAR(300)
		,[GolesEnContraPorPartido]	  VARCHAR(300)
		,[DisparosPuertaContra]		  VARCHAR(300)
		,[Salvadas]					  VARCHAR(300)
		,[%Salvadas]				  VARCHAR(300)
		,[PartidosGanados]			  VARCHAR(300)
		,[PartidosEmpatados]		  VARCHAR(300)
		,[PartidosPerdidos]			  VARCHAR(300)
		,[PartidosPorteriaCero]		  VARCHAR(300)
		,[%PartidosPorteriaCero]	  VARCHAR(300)
		,[PenalesIntentados]		  VARCHAR(300)
		,[PenalesConcedidos]		  VARCHAR(300)
		,[PenalesDetenidos]			  VARCHAR(300)
		,[PenalesFallidos]			  VARCHAR(300)
		,[%PenalesSalvados]			  VARCHAR(300)
		,[Partidos]					  VARCHAR(300)

	);

	WHILE @i > 0 AND (SELECT TOP 1 archivo FROM #tmpBuscaFiles) <> 'File Not Found'
	BEGIN
		BEGIN TRY	
			SET @file = (SELECT archivo FROM #tmpBuscaFiles WHERE a = @i);
			SET @fnr = @Ruta + @file;
			PRINT @fnr


			IF OBJECT_ID('tempdb..#tmpPorterosQA') IS NOT NULL DROP TABLE #tmpPorterosQA;
			CREATE TABLE #tmpPorterosQA (
				 [Jugador]				      VARCHAR(200)
				,[Pais]					      VARCHAR(50)
				,[Posc]					      VARCHAR(40)
				,[Equipo]				      VARCHAR(90)
				,[Edad]					      INT
				,[Nacimiento]			      INT
				,[PartidosJugados]			  INT
				,[Titular]					  INT
				,[Minutos]					  INT
				,[PartidosJugados2]			  DECIMAL(5,2)
				,[GolesEnContra]			  INT
				,[GolesEnContraPorPartido]	  DECIMAL(5,2)
				,[DisparosPuertaContra]		  INT
				,[Salvadas]					  INT
				,[%Salvadas]				  DECIMAL(5,2)
				,[PartidosGanados]			  INT
				,[PartidosEmpatados]		  INT
				,[PartidosPerdidos]			  INT
				,[PartidosPorteriaCero]		  INT
				,[%PartidosPorteriaCero]	  DECIMAL(5,2)
				,[PenalesIntentados]		  INT
				,[PenalesConcedidos]		  INT
				,[PenalesDetenidos]			  INT
				,[PenalesFallidos]			  INT
				,[%PenalesSalvados]			  DECIMAL(5,2)
				,[ImportDate]			      DATETIME
				,[Temporada]			      VARCHAR(30)
				,[Liga]					      VARCHAR(30)
			);


			EXEC('BULK INSERT #tmpPorteros FROM ''' + @fnr + ''' WITH (FIELDTERMINATOR = '','',ROWTERMINATOR = ''0X0A'',FORMAT = ''CSV'',CODEPAGE = ''65001'',BATCHSIZE=1000)');

			---- Limpieza de Datos ------------------------

			DELETE FROM #tmpPorteros WHERE ([Jugador] LIKE '%Jugador%' AND [Equipo] LIKE '%Equipo%') OR ([Jugador] IS NULL AND [Equipo] IS NULL);


			INSERT INTO #tmpPorterosQA
			SELECT [Jugador]			
				  ,[Pais]				
				  ,[Posc]				
				  ,[Equipo]				
				  ,YEAR(GETDATE())-CAST([Nacimiento] AS INT)					
				  ,CAST([Nacimiento]                 AS INT)
				  ,CAST([PartidosJugados]		     AS INT)
				  ,CAST([Titular]				     AS INT)
				  ,CAST(REPLACE([Minutos]	,',','')			     AS INT)
				  ,CAST([PartidosJugados2]		     AS DECIMAL(5,2))
				  ,CAST([GolesEnContra]			     AS INT)
				  ,CAST([GolesEnContraPorPartido]    AS DECIMAL(5,2))
				  ,CAST([DisparosPuertaContra]	     AS INT)
				  ,CAST([Salvadas]				     AS INT)
				  ,CAST([%Salvadas]				     AS DECIMAL(5,2))
				  ,CAST([PartidosGanados]		     AS INT)
				  ,CAST([PartidosEmpatados]		     AS INT)
				  ,CAST([PartidosPerdidos]		     AS INT)
				  ,CAST([PartidosPorteriaCero]	     AS INT)
				  ,CAST([%PartidosPorteriaCero]	     AS DECIMAL(5,2))
				  ,CAST([PenalesIntentados]		     AS INT)
				  ,CAST([PenalesConcedidos]		     AS INT)
				  ,CAST([PenalesDetenidos]		     AS INT)
				  ,CAST([PenalesFallidos]		     AS INT)
				  ,CAST([%PenalesSalvados]		     AS DECIMAL(5,2))
				  ,GETDATE()								  AS [ImportDate]
				  ,RIGHT(REPLACE(@file,'.csv','') ,9)         AS [Temporada]	
				  ,SUBSTRING(@file,1,CHARINDEX('_',@file)-1)  AS [Liga]						
			FROM #tmpPorteros;	
			

			--------------------------------------- Llave Borrado -------------

			--WITH CTE AS (SELECT ROW_NUMBER() OVER (PARTITION BY [Equipo] order by [Equipo] DESC) Rk  FROM #tmpPorterosQA)
			--DELETE FROM CTE WHERE Rk > 1;

			

			DELETE A FROM  tbPorteros A
			INNER JOIN #tmpPorterosQA B ON A.[Temporada] = B.[Temporada] AND A.[Liga] = B.[Liga] ;



			INSERT INTO [dbo].[tbPorteros]
			(					 
				 [Jugador]				     
				,[Pais]					     
				,[Posc]					     
				,[Equipo]				     
				,[Edad]					     
				,[Nacimiento]			     
				,[PartidosJugados]			 
				,[Titular]					 
				,[Minutos]					 
				,[PartidosJugados2]			 
				,[GolesEnContra]			 
				,[GolesEnContraPorPartido]	 
				,[DisparosPuertaContra]		 
				,[Salvadas]					 
				,[%Salvadas]				 
				,[PartidosGanados]			 
				,[PartidosEmpatados]		 
				,[PartidosPerdidos]			 
				,[PartidosPorteriaCero]		 
				,[%PartidosPorteriaCero]	 
				,[PenalesIntentados]		 
				,[PenalesConcedidos]		 
				,[PenalesDetenidos]			 
				,[PenalesFallidos]			 
				,[%PenalesSalvados]			 
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
				  ,[Titular]					 
				  ,[Minutos]					 
				  ,[PartidosJugados2]			 
				  ,[GolesEnContra]			 
				  ,[GolesEnContraPorPartido]	 
				  ,[DisparosPuertaContra]		 
				  ,[Salvadas]					 
				  ,[%Salvadas]				 
				  ,[PartidosGanados]			 
				  ,[PartidosEmpatados]		 
				  ,[PartidosPerdidos]			 
				  ,[PartidosPorteriaCero]		 
				  ,[%PartidosPorteriaCero]	 
				  ,[PenalesIntentados]		 
				  ,[PenalesConcedidos]		 
				  ,[PenalesDetenidos]			 
				  ,[PenalesFallidos]			 
				  ,[%PenalesSalvados]			 
				  ,[ImportDate]			     
				  ,[Temporada]			     
				  ,[Liga]	
			FROM #tmpPorterosQA;
		
		
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
		
		TRUNCATE TABLE #tmpPorteros;

		--Se disminuye el número de archivos pendientes en 1
		SET @i = @i - 1;

		--Fin del ciclo
		END
		
		IF OBJECT_ID('tempdb..#OuFiles') IS NOT NULL DROP TABLE #OuFiles;
		IF OBJECT_ID('tempdb..#tmpPorteros') IS NOT NULL DROP TABLE #tmpPorteros;
		IF OBJECT_ID('tempdb..#tmpPorterosQA') IS NOT NULL DROP TABLE #tmpPorterosQA;
	
	IF @Severity = 1
	BEGIN
		RAISERROR('Error en Bloque Try',16,1);
	END

--Fin del procedimiento almacenado


