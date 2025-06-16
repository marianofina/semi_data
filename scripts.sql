CREATE DATABASE seminario_db;
GO


USE seminario_db;
GO


CREATE TABLE usuarios (
   id INT PRIMARY KEY IDENTITY,
   username NVARCHAR(100) UNIQUE NOT NULL,
   password NVARCHAR(255) NOT NULL,
   fecha_nac DATETIME NOT NULL,
   fecha_creacion DATETIME DEFAULT GETDATE()
);
GO


CREATE TABLE admins (
   id INT PRIMARY KEY IDENTITY,
   username NVARCHAR(100) UNIQUE NOT NULL,
   password NVARCHAR(255) NOT NULL,
   fecha_creacion DATETIME DEFAULT GETDATE()
);
GO


CREATE TABLE config_usuarios (
   id INT PRIMARY KEY IDENTITY,
   fk_usuario_id INT FOREIGN KEY REFERENCES usuarios(id) ON DELETE CASCADE,
   notificaciones_activadas BIT DEFAULT 1
);
GO


CREATE TABLE portales_noticia (
   id INT PRIMARY KEY IDENTITY,
   nombre NVARCHAR(100) NOT NULL,
   logo NVARCHAR(100),
   url_base NVARCHAR(255) NOT NULL
);
GO


CREATE TABLE tematica_noticias (
   id INT PRIMARY KEY IDENTITY,
   nombre NVARCHAR(100) NOT NULL
);
GO


CREATE TABLE noticia (
   id INT PRIMARY KEY IDENTITY,
   titulo NVARCHAR(255) NOT NULL,
   contenido NVARCHAR(MAX) NOT NULL,
   resumen NVARCHAR(MAX),
   fecha_publicacion DATETIME DEFAULT GETDATE(),
   portal_id INT FOREIGN KEY REFERENCES portales_noticia(id),
   tematica_id INT FOREIGN KEY REFERENCES tematica_noticias(id),
   autor NVARCHAR(100)
);
GO


CREATE TABLE preferencia_noticias_usuario (
   id INT PRIMARY KEY IDENTITY,
   usuario_id INT FOREIGN KEY REFERENCES usuarios(id) ON DELETE CASCADE,
   tematica_id INT FOREIGN KEY REFERENCES tematica_noticias(id),
   interesa BIT NOT NULL
);
GO


CREATE TABLE interaccion_noticia_usuario (
   id INT PRIMARY KEY IDENTITY,
   usuario_id INT FOREIGN KEY REFERENCES usuarios(id) ON DELETE CASCADE,
   noticia_id INT FOREIGN KEY REFERENCES noticia(id) ON DELETE CASCADE,
   fecha_leido DATETIME,
   utilidad INT CHECK (utilidad BETWEEN 0 AND 5),
   resumen_claro INT CHECK (resumen_claro BETWEEN 0 AND 5)
);
GO


CREATE TABLE noticias_favoritas (
   id INT PRIMARY KEY IDENTITY,
   usuario_id INT FOREIGN KEY REFERENCES usuarios(id) ON DELETE CASCADE,
   noticia_id INT FOREIGN KEY REFERENCES noticia(id) ON DELETE CASCADE,
);
GO;

CREATE TABLE portales_bloq (
    id INT PRIMARY KEY IDENTITY,
    usuario_id INT FOREIGN KEY REFERENCES usuarios(id) ON DELETE CASCADE,
    portal_id INT FOREIGN KEY REFERENCES portales_noticia(id) ON DELETE CASCADE,
    bloq BIT NOT NULL DEFAULT 1
);
GO;
