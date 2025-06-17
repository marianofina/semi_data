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
   autor NVARCHAR(100),
    url_original nvarchar(max)
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

create procedure preferencias_tot_usuario
    @id_usuario int
as
    begin
        SELECT
            tn.id,
            tn.nombre,
            IIF(pnu.interesa = 1, 1, 0) AS interesa
        FROM tematica_noticias tn
        LEFT JOIN preferencia_noticias_usuario pnu
            ON tn.id = pnu.tematica_id AND pnu.usuario_id = @id_usuario;
    end;
GO;

create procedure portales_total_bloq
    @usuario_id int
    as
        select
            portales_noticia.id,
            nombre,
            logo,
            url_base,
            iif(bloq = 0 or bloq is null, 0, 1) as bloqueado
        from portales_noticia
        left join portales_bloq
            on portales_noticia.id = portales_bloq.portal_id
            and portales_bloq.usuario_id = @usuario_id;
GO;

create procedure obtener_noticias_usuario
    @usuario_id int
    as
SELECT
    noticia.id,
    noticia.titulo,
    noticia.resumen,
    noticia.fecha_publicacion,
    noticia.url_original,
    noticia.portal_id,
    portales_noticia.nombre as portal_nombre,
    tematica_noticias.id as tematica_id,
    tematica_noticias.nombre as tematica_nombre,
    noticia.autor,
    interaccion_noticia_usuario.id as interaccion_id,
    interaccion_noticia_usuario.fecha_leido,
    interaccion_noticia_usuario.utilidad,
    interaccion_noticia_usuario.resumen_claro
FROM noticia
LEFT JOIN interaccion_noticia_usuario
  ON noticia.id = interaccion_noticia_usuario.noticia_id
  AND interaccion_noticia_usuario.usuario_id = @usuario_id
INNER JOIN portales_noticia
  ON noticia.portal_id = portales_noticia.id
INNER JOIN tematica_noticias
  ON noticia.tematica_id = tematica_noticias.id
INNER JOIN preferencia_noticias_usuario
  ON preferencia_noticias_usuario.usuario_id = @usuario_id
  AND preferencia_noticias_usuario.tematica_id = noticia.tematica_id
LEFT JOIN portales_bloq
  ON portales_bloq.portal_id = noticia.portal_id
  AND portales_bloq.usuario_id = @usuario_id
WHERE (portales_bloq.portal_id IS NULL or portales_bloq.bloq = 0)
  AND noticia.resumen IS NOT NULL
  AND preferencia_noticias_usuario.interesa = @usuario_id
order by noticia.fecha_publicacion desc;
go;

create procedure get_noticia_usuario
    @usuario_id int,
    @noticia_id int
as
SELECT
    noticia.id,
    noticia.titulo,
    noticia.resumen,
    noticia.fecha_publicacion,
    noticia.url_original,
    noticia.portal_id,
    portales_noticia.nombre as portal_nombre,
    tematica_noticias.id as tematica_id,
    tematica_noticias.nombre as tematica_nombre,
    noticia.autor,
    interaccion_noticia_usuario.id as interaccion_id,
    interaccion_noticia_usuario.fecha_leido,
    interaccion_noticia_usuario.utilidad,
    interaccion_noticia_usuario.resumen_claro
FROM noticia
INNER JOIN tematica_noticias
    ON noticia.tematica_id = tematica_noticias.id
INNER JOIN portales_noticia
    ON noticia.portal_id = portales_noticia.id
LEFT JOIN interaccion_noticia_usuario
    ON noticia.id = interaccion_noticia_usuario.noticia_id
   AND interaccion_noticia_usuario.usuario_id = @usuario_id
WHERE noticia.id = @noticia_id;
go;
