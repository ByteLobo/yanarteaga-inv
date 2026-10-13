--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4
-- Dumped by pg_dump version 16.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: msib; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA msib;


--
-- Name: dblink; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS dblink WITH SCHEMA public;


--
-- Name: EXTENSION dblink; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION dblink IS 'connect to other PostgreSQL databases from within a database';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: actasactivofijo; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.actasactivofijo (
    actaaf_id character(36) NOT NULL,
    actaaf_fecha date NOT NULL,
    actaaf_nro_documento character varying(40) NOT NULL,
    actaaf_createuser character varying(40) NOT NULL,
    actaaf_createdate timestamp without time zone NOT NULL,
    actaaf_cusde_id integer NOT NULL,
    actaaf_cusa_id integer NOT NULL,
    actaaf_respon_id integer NOT NULL,
    actaaf_updateuser character varying(40) NOT NULL,
    actaaf_updatedate timestamp without time zone NOT NULL,
    actaaf_notas text NOT NULL,
    actaaf_fecha_aprobacion date NOT NULL,
    tipdoc_id smallint NOT NULL,
    actaaf_estadoacta_id integer NOT NULL
);


--
-- Name: actasactivofijoaf; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.actasactivofijoaf (
    actaaf_id character(36) NOT NULL,
    actfij_id character(36) NOT NULL,
    actaaf_af_conservacion_id integer NOT NULL,
    actaaf_af_ofi_id smallint NOT NULL,
    actaaf_af_ubicacion_area character varying(40) NOT NULL,
    actaaf_ac_ubicacion_ambiente smallint NOT NULL
);


--
-- Name: activofijo; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.activofijo (
    actfij_id character(36) NOT NULL,
    actfij_codigo character varying(20) NOT NULL,
    actfij_descripcion character varying(200) NOT NULL,
    actfij_caracteristica text NOT NULL,
    actfij_serie character varying(40) NOT NULL,
    actfij_precio_compra_ml numeric(7,2) NOT NULL,
    actfij_costo_activo_ml numeric(7,2) NOT NULL,
    actfij_conservacion_id integer NOT NULL,
    actfij_estado_bien_id integer NOT NULL,
    actfij_is_depreciar boolean NOT NULL,
    actfij_depreciar_valor_residual numeric(7,2) NOT NULL,
    actfij_depreciar_valor_depreciable numeric(7,2) NOT NULL,
    actfij_depreciar_vidautil smallint NOT NULL,
    actfij_modelo character varying(40) NOT NULL,
    actfij_marca character varying(40) NOT NULL,
    actfij_fecha_adquisicion date NOT NULL,
    actfij_nro_factura integer NOT NULL,
    actfij_nro_oc character varying(20) NOT NULL,
    prv_id smallint NOT NULL,
    actfij_codigo_anterior character varying(20) NOT NULL,
    catitm_id smallint NOT NULL,
    actfij_garantia boolean NOT NULL,
    actfij_tiempo_garantia smallint NOT NULL,
    ofi_id smallint NOT NULL,
    actfij_ubicacion_area character varying(100) NOT NULL,
    actfij_ubicacion_ambiente character varying(100) NOT NULL,
    actfij_estado_bien_descripcion character varying(200) NOT NULL,
    actfij_conservacion_descripcion character varying(200) NOT NULL,
    actfij_cus_id integer NOT NULL,
    actfij_cus_fecha_asignacion date NOT NULL,
    actfij_observacion text NOT NULL,
    actfij_estado_custodia_id integer NOT NULL,
    actfij_createuser character varying(40) NOT NULL,
    actfij_createdate timestamp without time zone NOT NULL,
    actfij_updateuser character varying(40) NOT NULL,
    actfij_updatedate timestamp without time zone NOT NULL,
    actfij_fecha_alta date NOT NULL
);


--
-- Name: activofijohistorialestado; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.activofijohistorialestado (
    actfijhis_id character(36) NOT NULL,
    actifijhis_fecharegistro timestamp without time zone NOT NULL,
    actfijhis_descripcion text NOT NULL,
    actfijhis_createuser character varying(40) NOT NULL,
    actfijhis_createdate timestamp without time zone NOT NULL,
    actfij_id character(36) NOT NULL,
    actfijhis_estado_activo_id integer NOT NULL,
    actfijhis_guid_ref_documento character(36) NOT NULL
);


--
-- Name: almacen; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.almacen (
    alm_id smallint NOT NULL,
    alm_nombre character varying(60) NOT NULL,
    ofi_id smallint NOT NULL,
    alm_activo smallint NOT NULL,
    alm_fecha_inicio_operacion date NOT NULL,
    alm_createdate timestamp without time zone NOT NULL,
    alm_createuser character varying(40) NOT NULL,
    alm_updatedate timestamp without time zone NOT NULL,
    alm_updateuser character varying(40) NOT NULL,
    almfuefin_id integer NOT NULL
);


--
-- Name: almacencatalogoitem; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.almacencatalogoitem (
    almcataitmalm_id smallint NOT NULL,
    cataitm_id character varying(20) NOT NULL,
    almcataitm_control_stock smallint NOT NULL,
    almcataitm_stock_min numeric(7,2) NOT NULL,
    almcataitm_stock_max numeric(7,2) NOT NULL,
    almcataitm_control_vencimiento smallint NOT NULL,
    almcataitm_activo smallint NOT NULL,
    almcataitm_control_saldo smallint NOT NULL,
    almcataitm_createuser character varying(40) NOT NULL,
    almcataitm_createdate timestamp without time zone NOT NULL,
    almcataitm_updateuser character varying(40) NOT NULL,
    almcataitm_updatedate timestamp without time zone NOT NULL,
    almcataitm_bloqueoif smallint
);


--
-- Name: asignacionpersonal; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.asignacionpersonal (
    asgper_id integer NOT NULL,
    asgperper_id integer NOT NULL,
    asgpercar_id smallint NOT NULL,
    asgper_fecha_inicio date NOT NULL,
    asgper_fecha_final date NOT NULL,
    asgper_asignacion_fill character varying(100) NOT NULL,
    asgper_activo smallint NOT NULL
);


--
-- Name: autorizacionanulacion; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.autorizacionanulacion (
    autanu_id character(36) NOT NULL,
    autanu_fecha_solicitud timestamp without time zone NOT NULL,
    autanu_username_solicitud character varying(40) NOT NULL,
    autanu_nota text NOT NULL,
    autanu_transaccion_id character(36) NOT NULL,
    autanu_transaccion_tipo smallint NOT NULL,
    autanu_estado_id integer NOT NULL,
    autanu_fecha_respuesta timestamp without time zone NOT NULL,
    ofi_id smallint NOT NULL,
    autanu_fecha_registro date NOT NULL,
    autanu_username_respuesta character varying(40) NOT NULL,
    autanuper_id integer NOT NULL,
    solanuper_id integer NOT NULL,
    autanu_transaccion_descripcion text NOT NULL
);


--
-- Name: cargo; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.cargo (
    car_id smallint NOT NULL,
    car_nombre character varying(60) NOT NULL,
    car_active smallint NOT NULL
);


--
-- Name: catalogoitem; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.catalogoitem (
    cataitm_id character varying(20) NOT NULL,
    cataitm_nombre character varying(60) NOT NULL,
    catitm_id smallint NOT NULL,
    cataitm_activo smallint NOT NULL,
    cataitmunimed_id integer NOT NULL,
    cataitm_cod_secuencial character varying(10) NOT NULL,
    cataitm_createuser character varying(40) NOT NULL,
    cataitm_createdate timestamp without time zone NOT NULL,
    cataitm_updateuser character varying(40) NOT NULL,
    cataitm_updatedate timestamp without time zone NOT NULL,
    cataitm_descripcion_fck text NOT NULL,
    cataitm_crs_id_item integer NOT NULL,
    cataitm_crs_id_categoria smallint NOT NULL
);


--
-- Name: catalogoitemdigital; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.catalogoitemdigital (
    cataitm_id character varying(20) NOT NULL,
    cataitmdig_repdig_id character(36) NOT NULL,
    cataitmdig_fecha timestamp without time zone NOT NULL,
    cataitmdig_nombre character varying(80) NOT NULL,
    cataitmdig_descripcion text NOT NULL,
    cataitmdig_esprincipal smallint NOT NULL,
    cataitmdig_createuser character varying(40) NOT NULL,
    cataitmdig_createdate timestamp without time zone NOT NULL,
    cataitmdig_updateuser character varying(40) NOT NULL,
    cataitmdig_updatedate timestamp without time zone NOT NULL,
    cataitmdig_tipo_archivo character varying(30) NOT NULL
);


--
-- Name: categoriaitem; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.categoriaitem (
    catitm_id smallint NOT NULL,
    catitm_nombre character varying(60) NOT NULL,
    catitm_activo smallint NOT NULL,
    gruitm_id smallint NOT NULL,
    catitm_createuser character varying(40) NOT NULL,
    catitm_createdate timestamp without time zone NOT NULL,
    catitm_updateuser character varying(40) NOT NULL,
    catitm_updatedate timestamp without time zone NOT NULL,
    catitm_cod_secuencial character varying(6) NOT NULL
);


--
-- Name: centrocosto; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.centrocosto (
    ccos_id integer NOT NULL,
    ccos_nombre character varying(60) NOT NULL,
    ccos_activo smallint NOT NULL,
    ccosgru_id integer NOT NULL
);


--
-- Name: familiaitem; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.familiaitem (
    famitm_id smallint NOT NULL,
    famitm_cod_secuencial character varying(6) NOT NULL,
    famitm_nombre character varying(100) NOT NULL,
    famitm_activo smallint NOT NULL,
    famitm_prefijo character varying(4) NOT NULL,
    famitm_nro_correlativo smallint NOT NULL,
    famitm_tipo character varying(20) NOT NULL
);


--
-- Name: flujoaprobaciondocumento; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.flujoaprobaciondocumento (
    fluaprdoc_id character(36) NOT NULL,
    fluaprdoc_fecha_aprobacion date NOT NULL,
    fluaprdoc_fecha_audit timestamp without time zone NOT NULL,
    fluaprdoc_personal_id integer NOT NULL,
    fluaprdoc_personal_nombres_fill character varying(80) NOT NULL,
    fluaprdoc_cargo_nombre character varying(40) NOT NULL,
    fluaprdoc_activo smallint NOT NULL,
    fluaprdoc_referencia_id character(36) NOT NULL,
    fluaprdoc_createuser character varying(40) NOT NULL,
    fluaprdoc_createdate timestamp without time zone NOT NULL,
    fluaprdoc_updateuser character varying(40) NOT NULL,
    fluaprdoc_updatedate timestamp without time zone NOT NULL,
    fluaprdoc_fecha_creacion timestamp without time zone NOT NULL,
    fluaprdoc_tenor character varying(40) NOT NULL,
    fluaprdoc_control_aprobado smallint NOT NULL,
    fluaprdoc_nota text NOT NULL,
    fluaprdoc_estado_documento_id integer NOT NULL
);


--
-- Name: grupoitem; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.grupoitem (
    gruitm_id smallint NOT NULL,
    gruitm_nombre character varying(100) NOT NULL,
    gruitm_activo smallint NOT NULL,
    gruitm_cod_secuencial character varying(6) NOT NULL,
    famitm_id smallint
);


--
-- Name: ingresoalmacen; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.ingresoalmacen (
    ingalm_id character(36) NOT NULL,
    ingalm_fecha_registro date NOT NULL,
    ingalm_fecha_auditoria timestamp without time zone NOT NULL,
    ingalm_nro_documento character varying(12) NOT NULL,
    ingalmalmori_id smallint NOT NULL,
    ingalmalmdes_id smallint NOT NULL,
    ingalm_nota text NOT NULL,
    ingalm_fecha_almacen date NOT NULL,
    ingalmalm_id smallint NOT NULL,
    ingalmprv_id smallint NOT NULL,
    ingalm_serial_item smallint NOT NULL,
    ingalmasgper_id integer NOT NULL,
    ingalm_nro_folio integer NOT NULL,
    ingalm_nro_orden character varying(40) NOT NULL,
    ingalmtipdoc_id smallint NOT NULL,
    ingalm_estado_id integer NOT NULL,
    ingalm_tipo_proveedor character varying(20) NOT NULL,
    ingalm_createuser character varying(40) NOT NULL,
    ingalm_createdate timestamp without time zone NOT NULL,
    ingalm_updateuser character varying(40) NOT NULL,
    ingalm_updatedate timestamp without time zone NOT NULL,
    ingalm_ref_transferencia_salalm_id character(36) NOT NULL,
    ingalm_glosa character varying(300) NOT NULL,
    ingalmfuefin_id integer NOT NULL,
    ingalm_cerrar_inventario_mes smallint NOT NULL,
    ingalm_nro_compra character(20),
    ingalm_nro_factura character(10)
);


--
-- Name: ingresoalmacenitem; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.ingresoalmacenitem (
    ingalm_id character(36) NOT NULL,
    ingalmitm_id smallint NOT NULL,
    cataitm_id character varying(20) NOT NULL,
    ingalmitm_costo_unitario numeric(9,2) NOT NULL,
    ingalmitm_lote character varying(20),
    ingalmitm_fecha_exp date,
    almcataitmalm_id smallint NOT NULL,
    ingalmitm_cantidad_ingreso integer NOT NULL,
    ingalmitm_cantidad_salida integer NOT NULL,
    ingalmitm_almitmdis_idref character(36) NOT NULL,
    ingalmitm_cantidad_ajuste integer NOT NULL,
    ingalmitmfuefin_id integer NOT NULL,
    ingalmitm_costo_unitario_con_imp numeric(9,2) NOT NULL,
    ingalmitm_ptje_impuesto numeric(4,1) NOT NULL,
    ingalmitm_cantidad_ingreso_ajuste integer NOT NULL
);


--
-- Name: inventariofisico; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.inventariofisico (
    invfis_id character(36) NOT NULL,
    invfis_nro_documento character varying(20) NOT NULL,
    invfis_fecha date NOT NULL,
    invfis_estado integer NOT NULL,
    invfis_nombre_encargado character varying(60) NOT NULL,
    invfis_createdate timestamp without time zone NOT NULL,
    invfis_createuser character varying(40) NOT NULL,
    invfis_notas text NOT NULL,
    invfisalm_id smallint NOT NULL,
    invfis_fecha_conclusion date NOT NULL
);


--
-- Name: inventariofisicoitems; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.inventariofisicoitems (
    invfis_id character(36) NOT NULL,
    invfisitm_id integer NOT NULL,
    almcataitmalm_id smallint NOT NULL,
    cataitm_id character varying(20) NOT NULL,
    almitmdisfuefin_id integer NOT NULL,
    invfisitm_costo_unitario numeric(7,2) NOT NULL,
    invfisitm_lote character varying(20) NOT NULL,
    invfisitm_fecha_exp date NOT NULL,
    invfisitm_cantidad_actual integer NOT NULL,
    invfisitm_cantidad_fisico integer NOT NULL,
    invfisitm_observacion character varying(200) NOT NULL,
    invfisitm_estado character varying(20) NOT NULL
);


--
-- Name: kardexconsolidadomensual; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.kardexconsolidadomensual (
    karconmes_id character(36) NOT NULL,
    karconmes_mes smallint NOT NULL,
    karconmes_anio smallint NOT NULL,
    almcataitmalm_id smallint NOT NULL,
    cataitm_id character varying(20) NOT NULL,
    karconmes_lote character varying(20) NOT NULL,
    karconmes_fecha_exp date NOT NULL,
    karconmes_costo_unitario numeric(9,2) NOT NULL,
    karconmes_cantidad_ingreso integer NOT NULL,
    karconmes_cantidad_ajuste integer NOT NULL,
    karconmes_cantidad_salida integer NOT NULL,
    almitmdisfuefin_id integer,
    karconmes_cantidad_saldo_anterior integer NOT NULL,
    karconmes_costo_saldo_anterior numeric(9,2) NOT NULL,
    karconmes_costo_ingreso numeric(9,2) NOT NULL,
    karconmes_costo_salida numeric(9,2) NOT NULL,
    karconmes_costo_ajuste numeric(9,2) NOT NULL,
    karconmes_cantidad_traspasos integer NOT NULL,
    karconmes_costo_traspaso numeric(9,2) NOT NULL
);


--
-- Name: salidaalmacen; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.salidaalmacen (
    salalm_id character(36) NOT NULL,
    salalm_fecha_registro date NOT NULL,
    salalm_fecha_auditoria timestamp without time zone NOT NULL,
    salalm_fecha_almacen date NOT NULL,
    salalm_nro_documento character varying(20) NOT NULL,
    salalmalmori_id smallint NOT NULL,
    salalmalmdes_id smallint NOT NULL,
    salalmalm_id smallint NOT NULL,
    salalmprv_id smallint NOT NULL,
    salalm_serial_item smallint NOT NULL,
    salalmasgper_id integer NOT NULL,
    salalmnota text NOT NULL,
    salalm_nro_folio integer NOT NULL,
    salalm_nro_orden character varying(40) NOT NULL,
    salalmtipdoc_id smallint NOT NULL,
    salalm_estado_id integer NOT NULL,
    salalm_createuser character varying(40) NOT NULL,
    salalm_createdate timestamp without time zone NOT NULL,
    salalm_updateuser character varying(40) NOT NULL,
    salalm_updatedate timestamp without time zone NOT NULL,
    salalm_tipo_proveedor character varying(20) NOT NULL,
    salalm_ref_transferencia_ingalm_id character(36) NOT NULL,
    salalm_glosa character varying(300) NOT NULL,
    salalm_estadotrans_id integer,
    salalmfuefin_id integer,
    salalm_cerrar_inventario_mes smallint NOT NULL,
    salalm_es_campania_centro boolean
);


--
-- Name: salidaalmacenitem; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.salidaalmacenitem (
    salalm_id character(36) NOT NULL,
    salalmitm_id smallint NOT NULL,
    almcataitmalm_id smallint NOT NULL,
    cataitm_id character varying(20) NOT NULL,
    salalmitm_cantidad_salida integer NOT NULL,
    salalmitm_costo_unitario numeric(9,2) NOT NULL,
    salalmitm_lote character varying(20) NOT NULL,
    salalmitm_fecha_exp date NOT NULL,
    ingalm_id_referencia character(36) NOT NULL,
    ingalmitm_id_referencia smallint NOT NULL,
    salalmitm_almitmdis_idref character(36),
    salalmitm_cantidad_ajuste integer NOT NULL,
    salalmitm_glosa character varying(200) NOT NULL,
    salalmitmfuefin_id integer NOT NULL
);


--
-- Name: kardexmovimientoitem; Type: VIEW; Schema: msib; Owner: -
--

CREATE VIEW msib.kardexmovimientoitem AS
 SELECT sv.karmovitm_id,
    (sv.karmovitm_detalle_id)::bigint AS karmovitm_detalle_id,
    sv.karmovitm_nro_orden,
    sv.almcataitmalm_id,
    sv.cataitm_id,
    sv.karmovitm_fecha,
    (sv.karmovitm_tipo)::character varying(10) AS karmovitm_tipo,
    sv.tipdoc_id,
    (sv.karmovitm_nro_documento)::character varying(40) AS karmovitm_nro_documento,
    sv.karmovitm_glosa,
    (sv.karmovitm_lote)::character varying(40) AS karmovitm_lote,
    sv.karmovitm_fecha_exp,
    sv.karmovitm_cantidad_ingreso,
    sv.karmovitm_cantidad_salida,
    sv.karmovitm_estado,
    (sv.karmovitm_costo_ingreso)::numeric(9,2) AS karmovitm_costo_ingreso,
    (sv.karmovitm_costo_salida)::numeric(9,2) AS karmovitm_costo_salida,
    sv.karmovitm_cantidad_ajuste,
    sv.karmovitm_transaccion_id,
    sv.karmovitm_transaccionitem_id,
    sv.karmovitm_fuefin_id,
    (sv.karmovitm_costo_ajuste)::numeric(9,2) AS karmovitm_costo_ajuste,
    (sv.karmovitm_costo_unitario)::numeric(7,2) AS karmovitm_costo_unitario,
    (sv.karmovitm_almacen_origen_destino)::character varying(120) AS karmovitm_almacen_origen_destino,
    (sv.karmovitm_usuario)::character varying(60) AS karmovitm_usuario
   FROM ( SELECT t1.ingalm_id AS karmovitm_id,
            t1.ingalmitm_id AS karmovitm_detalle_id,
            t2.ingalm_nro_orden AS karmovitm_nro_orden,
            t1.almcataitmalm_id,
            t1.cataitm_id,
            t2.ingalm_fecha_almacen AS karmovitm_fecha,
            'INGRESO'::text AS karmovitm_tipo,
            t2.ingalmtipdoc_id AS tipdoc_id,
            t2.ingalm_nro_documento AS karmovitm_nro_documento,
            t2.ingalm_glosa AS karmovitm_glosa,
            t1.ingalmitm_lote AS karmovitm_lote,
            t1.ingalmitm_fecha_exp AS karmovitm_fecha_exp,
            t1.ingalmitm_cantidad_ingreso AS karmovitm_cantidad_ingreso,
            0 AS karmovitm_cantidad_salida,
            t2.ingalm_estado_id AS karmovitm_estado,
            (((t1.ingalmitm_cantidad_ingreso + t1.ingalmitm_cantidad_ingreso_ajuste))::numeric * (t1.ingalmitm_costo_unitario)::numeric(20,10)) AS karmovitm_costo_ingreso,
            0 AS karmovitm_costo_salida,
            t1.ingalmitm_cantidad_ingreso_ajuste AS karmovitm_cantidad_ajuste,
            t1.ingalm_id AS karmovitm_transaccion_id,
            t1.ingalmitm_id AS karmovitm_transaccionitem_id,
            t1.ingalmitmfuefin_id AS karmovitm_fuefin_id,
            0 AS karmovitm_costo_ajuste,
            t1.ingalmitm_costo_unitario AS karmovitm_costo_unitario,
            COALESCE(t5.karmovitm_almacen_origen_destino, ''::text) AS karmovitm_almacen_origen_destino,
            t2.ingalm_updateuser AS karmovitm_usuario
           FROM ((msib.ingresoalmacenitem t1
             JOIN msib.ingresoalmacen t2 ON ((t2.ingalm_id = t1.ingalm_id)))
             JOIN ( SELECT (((t7.alm_nombre)::text || ' / '::text) || (t8.alm_nombre)::text) AS karmovitm_almacen_origen_destino,
                    t6.ingalm_id
                   FROM ((msib.ingresoalmacen t6
                     JOIN msib.almacen t7 ON ((t7.alm_id = t6.ingalmalmori_id)))
                     JOIN msib.almacen t8 ON ((t8.alm_id = t6.ingalmalmdes_id)))) t5 ON ((t5.ingalm_id = t1.ingalm_id)))
          WHERE (t2.ingalm_estado_id = 5002)) sv
UNION
 SELECT sv.karmovitm_id,
    (sv.karmovitm_detalle_id)::bigint AS karmovitm_detalle_id,
    sv.karmovitm_nro_orden,
    sv.almcataitmalm_id,
    sv.cataitm_id,
    sv.karmovitm_fecha,
    (sv.karmovitm_tipo)::character varying(10) AS karmovitm_tipo,
    sv.tipdoc_id,
    (sv.karmovitm_nro_documento)::character varying(40) AS karmovitm_nro_documento,
    sv.karmovitm_glosa,
    (sv.karmovitm_lote)::character varying(40) AS karmovitm_lote,
    sv.karmovitm_fecha_exp,
    sv.karmovitm_cantidad_ingreso,
    sv.karmovitm_cantidad_salida,
    sv.karmovitm_estado,
    (sv.karmovitm_costo_ingreso)::numeric(9,2) AS karmovitm_costo_ingreso,
    (sv.karmovitm_costo_salida)::numeric(9,2) AS karmovitm_costo_salida,
    sv.karmovitm_cantidad_ajuste,
    sv.karmovitm_transaccion_id,
    sv.karmovitm_transaccionitem_id,
    sv.karmovitm_fuefin_id,
    (sv.karmovitm_costo_ajuste)::numeric(9,2) AS karmovitm_costo_ajuste,
    (sv.karmovitm_costo_unitario)::numeric(7,2) AS karmovitm_costo_unitario,
    (sv.karmovitm_almacen_origen_destino)::character varying(120) AS karmovitm_almacen_origen_destino,
    (sv.karmovitm_usuario)::character varying(60) AS karmovitm_usuario
   FROM ( SELECT t1.salalm_id AS karmovitm_id,
            t1.salalmitm_id AS karmovitm_detalle_id,
            t2.salalm_nro_orden AS karmovitm_nro_orden,
            t1.almcataitmalm_id,
            t1.cataitm_id,
            t2.salalm_fecha_almacen AS karmovitm_fecha,
            'SALIDA'::text AS karmovitm_tipo,
            t2.salalmtipdoc_id AS tipdoc_id,
            t2.salalm_nro_documento AS karmovitm_nro_documento,
            t2.salalm_glosa AS karmovitm_glosa,
            t1.salalmitm_lote AS karmovitm_lote,
            t1.salalmitm_fecha_exp AS karmovitm_fecha_exp,
            0 AS karmovitm_cantidad_ingreso,
            t1.salalmitm_cantidad_salida AS karmovitm_cantidad_salida,
            t2.salalm_estado_id AS karmovitm_estado,
            0 AS karmovitm_costo_ingreso,
            (((t1.salalmitm_cantidad_salida + t1.salalmitm_cantidad_ajuste))::numeric * (t1.salalmitm_costo_unitario)::numeric(20,10)) AS karmovitm_costo_salida,
            t1.salalmitm_cantidad_ajuste AS karmovitm_cantidad_ajuste,
            t1.ingalm_id_referencia AS karmovitm_transaccion_id,
            t1.ingalmitm_id_referencia AS karmovitm_transaccionitem_id,
            t1.salalmitmfuefin_id AS karmovitm_fuefin_id,
            0 AS karmovitm_costo_ajuste,
            t1.salalmitm_costo_unitario AS karmovitm_costo_unitario,
            COALESCE(t5.karmovitm_almacen_origen_destino, ''::text) AS karmovitm_almacen_origen_destino,
            t2.salalm_updateuser AS karmovitm_usuario
           FROM ((msib.salidaalmacenitem t1
             JOIN msib.salidaalmacen t2 ON ((t2.salalm_id = t1.salalm_id)))
             JOIN ( SELECT (((t7.alm_nombre)::text || ' / '::text) || (t8.alm_nombre)::text) AS karmovitm_almacen_origen_destino,
                    t6.salalm_id
                   FROM ((msib.salidaalmacen t6
                     JOIN msib.almacen t7 ON ((t7.alm_id = t6.salalmalmori_id)))
                     JOIN msib.almacen t8 ON ((t8.alm_id = t6.salalmalmdes_id)))) t5 ON ((t5.salalm_id = t1.salalm_id)))
          WHERE ((t2.salalm_estado_id = 5002) AND (t1.salalmitm_cantidad_ajuste = 0))) sv
UNION
 SELECT sv.karmovitm_id,
    (sv.karmovitm_detalle_id)::bigint AS karmovitm_detalle_id,
    sv.karmovitm_nro_orden,
    sv.almcataitmalm_id,
    sv.cataitm_id,
    sv.karmovitm_fecha,
    (sv.karmovitm_tipo)::character varying(10) AS karmovitm_tipo,
    sv.tipdoc_id,
    (sv.karmovitm_nro_documento)::character varying(40) AS karmovitm_nro_documento,
    sv.karmovitm_glosa,
    (sv.karmovitm_lote)::character varying(40) AS karmovitm_lote,
    sv.karmovitm_fecha_exp,
    sv.karmovitm_cantidad_ingreso,
    sv.karmovitm_cantidad_salida,
    sv.karmovitm_estado,
    (sv.karmovitm_costo_ingreso)::numeric(9,2) AS karmovitm_costo_ingreso,
    (sv.karmovitm_costo_salida)::numeric(9,2) AS karmovitm_costo_salida,
    sv.karmovitm_cantidad_ajuste,
    sv.karmovitm_transaccion_id,
    sv.karmovitm_transaccionitem_id,
    sv.karmovitm_fuefin_id,
    (sv.karmovitm_costo_ajuste)::numeric(9,2) AS karmovitm_costo_ajuste,
    (sv.karmovitm_costo_unitario)::numeric(7,2) AS karmovitm_costo_unitario,
    (sv.karmovitm_almacen_origen_destino)::character varying(120) AS karmovitm_almacen_origen_destino,
    (sv.karmovitm_usuario)::character varying(60) AS karmovitm_usuario
   FROM ( SELECT t1.salalm_id AS karmovitm_id,
            t1.salalmitm_id AS karmovitm_detalle_id,
            t2.salalm_nro_orden AS karmovitm_nro_orden,
            t1.almcataitmalm_id,
            t1.cataitm_id,
            t2.salalm_fecha_almacen AS karmovitm_fecha,
            'AJUSTE'::text AS karmovitm_tipo,
            t2.salalmtipdoc_id AS tipdoc_id,
            t2.salalm_nro_documento AS karmovitm_nro_documento,
            t2.salalm_glosa AS karmovitm_glosa,
            t1.salalmitm_lote AS karmovitm_lote,
            t1.salalmitm_fecha_exp AS karmovitm_fecha_exp,
            0 AS karmovitm_cantidad_ingreso,
            t1.salalmitm_cantidad_salida AS karmovitm_cantidad_salida,
            t2.salalm_estado_id AS karmovitm_estado,
            0 AS karmovitm_costo_ingreso,
            0 AS karmovitm_costo_salida,
            t1.salalmitm_cantidad_ajuste AS karmovitm_cantidad_ajuste,
            t1.ingalm_id_referencia AS karmovitm_transaccion_id,
            t1.ingalmitm_id_referencia AS karmovitm_transaccionitem_id,
            t1.salalmitmfuefin_id AS karmovitm_fuefin_id,
            (((t1.salalmitm_cantidad_salida + t1.salalmitm_cantidad_ajuste))::numeric * (t1.salalmitm_costo_unitario)::numeric(20,10)) AS karmovitm_costo_ajuste,
            t1.salalmitm_costo_unitario AS karmovitm_costo_unitario,
            COALESCE(t5.karmovitm_almacen_origen_destino, ''::text) AS karmovitm_almacen_origen_destino,
            t2.salalm_updateuser AS karmovitm_usuario
           FROM ((msib.salidaalmacenitem t1
             JOIN msib.salidaalmacen t2 ON ((t2.salalm_id = t1.salalm_id)))
             JOIN ( SELECT (((t7.alm_nombre)::text || ' / '::text) || (t8.alm_nombre)::text) AS karmovitm_almacen_origen_destino,
                    t6.salalm_id
                   FROM ((msib.salidaalmacen t6
                     JOIN msib.almacen t7 ON ((t7.alm_id = t6.salalmalmori_id)))
                     JOIN msib.almacen t8 ON ((t8.alm_id = t6.salalmalmdes_id)))) t5 ON ((t5.salalm_id = t1.salalm_id)))
          WHERE ((t2.salalm_estado_id = 5002) AND (t1.salalmitm_cantidad_salida = 0))) sv;


--
-- Name: kardexmovimientomensual; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.kardexmovimientomensual (
    karmovmes_id character(36) NOT NULL,
    karmovmes_mes smallint NOT NULL,
    karmovmes_anio smallint NOT NULL,
    almcataitmalm_id smallint NOT NULL,
    cataitm_id character varying(20) NOT NULL,
    karmovmes_cantidad_saldo_anterior integer NOT NULL,
    karmovmes_cantidad_ingreso integer NOT NULL,
    karmovmes_cantidad_salida integer NOT NULL,
    karmovmes_costo_saldo_anterior numeric(9,2) NOT NULL,
    karmovmes_costo_ingreso numeric(9,2) NOT NULL,
    karmovmes_costo_salida numeric(9,2) NOT NULL
);


--
-- Name: lineatelefonia; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.lineatelefonia (
    lintel_id character(36) NOT NULL,
    lintel_proveedor character varying(40) NOT NULL,
    lintel_numero integer NOT NULL,
    lintel_montoasignado numeric(5,2) NOT NULL,
    lintel_cargo character varying(100) NOT NULL,
    lintel_estadoid integer NOT NULL,
    lintel_ofi_id smallint NOT NULL,
    actfij_id character(36)
);


--
-- Name: logcierremesinventario; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.logcierremesinventario (
    logcieinv_mes smallint NOT NULL,
    logcieinv_anio smallint NOT NULL,
    logcieinv_fecha_registro timestamp without time zone NOT NULL,
    logcieinv_createuser character varying(40) NOT NULL,
    logcieinv_createdate timestamp without time zone NOT NULL,
    logcieinv_updateuser character varying(40) NOT NULL,
    logcieinv_updatedate timestamp without time zone NOT NULL,
    logcieinv_comentario text NOT NULL,
    logcieinv_cerrado_date timestamp without time zone,
    logcieinv_cerrado_user character varying(40),
    logcieinv_abierto_date timestamp without time zone NOT NULL,
    logcieinv_abierto_user character varying(40) NOT NULL,
    logcieinv_estado character varying(20) NOT NULL,
    logcieinv_fecha_inicio date NOT NULL,
    logcieinv_fecha_final date NOT NULL
);


--
-- Name: logcierremesinventarioalmacen; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.logcierremesinventarioalmacen (
    logcieinv_anio smallint NOT NULL,
    logcieinv_mes smallint NOT NULL,
    alm_id smallint NOT NULL,
    logcieinvalm_ultfecha date NOT NULL,
    logcieinvalm_estado_reconstuirsaldo smallint NOT NULL
);


--
-- Name: logtokenapicrs; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.logtokenapicrs (
    logtokcrs_id character(36) NOT NULL,
    logtokcrs_fecha_creacion timestamp without time zone NOT NULL,
    logtokcrs_fecha_expiracion timestamp without time zone NOT NULL,
    logtokcrs_token character varying(120) NOT NULL
);


--
-- Name: menuitemid; Type: SEQUENCE; Schema: msib; Owner: -
--

CREATE SEQUENCE msib.menuitemid
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: menuitem; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.menuitem (
    menuitemid smallint DEFAULT nextval('msib.menuitemid'::regclass) NOT NULL,
    menuitemcaption character varying(40) NOT NULL,
    menuitemorder smallint NOT NULL,
    menuitemfatherid smallint,
    menuitemtype smallint NOT NULL,
    menuitemlink character varying(60) NOT NULL,
    menuitemlinkparameters character varying(100) NOT NULL,
    menuitemlinktarget character varying(10) NOT NULL,
    menuitemiconclass character varying(40) NOT NULL,
    menuitemshowdevelopermenuoption boolean NOT NULL,
    menuitemshoweditmenuoptions boolean NOT NULL,
    secfunctionalityid bigint
);


--
-- Name: numerofolioalmacen; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.numerofolioalmacen (
    numfolalm_mes smallint NOT NULL,
    numfolalm_anio smallint NOT NULL,
    alm_id smallint NOT NULL,
    numfolalm_ultimo_folio integer NOT NULL
);


--
-- Name: oficinas; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.oficinas (
    ofi_id smallint NOT NULL,
    ofi_nombre character varying(100) NOT NULL,
    ofi_direccion character varying(1024) NOT NULL,
    ofi_telefono character(20) NOT NULL,
    ofi_activo smallint NOT NULL,
    ofican_id integer NOT NULL,
    ofi_id_nodo_superior smallint NOT NULL,
    ccos_id integer,
    ofi_crs_id smallint NOT NULL
);


--
-- Name: parametroconfiguracion; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.parametroconfiguracion (
    parcfg_id character varying(30) NOT NULL,
    parcfg_nombre character varying(60) NOT NULL,
    parcfg_descripcion text NOT NULL
);


--
-- Name: parametroconfiguracionitem; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.parametroconfiguracionitem (
    parcfg_id character varying(30) NOT NULL,
    parcfgitm_id character varying(40) NOT NULL,
    parcfgitm_valor character varying(120) NOT NULL,
    parcfgitm_descripcion character varying(300) NOT NULL
);


--
-- Name: personal; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.personal (
    per_id integer NOT NULL,
    per_nombres character varying(60) NOT NULL,
    per_primer_apellido character varying(60) NOT NULL,
    per_segundo_apellido character varying(60) NOT NULL,
    per_nombres_fill character varying(100) NOT NULL,
    per_nro_documento character varying(60) NOT NULL,
    per_activo smallint NOT NULL,
    per_createuser character varying(40) NOT NULL,
    per_createdate timestamp without time zone NOT NULL,
    per_updateuser character varying(40) NOT NULL,
    per_updatedate timestamp without time zone NOT NULL,
    per_cargo character varying(60) NOT NULL
);


--
-- Name: planificar_compra_ratio; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.planificar_compra_ratio (
    placomrat_id character(36) NOT NULL,
    placomrat_nombre character varying(80) NOT NULL,
    placomrat_periodicidad_pedido smallint NOT NULL,
    placomrat_fecha_ultimo_pedido date NOT NULL,
    placomrat_fecha_proximo_pedido date NOT NULL,
    placomrat_plazo_entrega numeric(3,1) NOT NULL,
    placomrat_anio smallint NOT NULL,
    placomrat_plantilla_simulador_id smallint NOT NULL,
    placomrat_mes smallint NOT NULL,
    placomrat_fecha_consulta date NOT NULL
);


--
-- Name: planificar_compra_ratio_item; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.planificar_compra_ratio_item (
    placomrat_id character(36) NOT NULL,
    cataitm_id character varying(20) NOT NULL,
    placomitm_consumo_datajson text NOT NULL
);


--
-- Name: planificar_compra_ratio_item_almacen; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.planificar_compra_ratio_item_almacen (
    placomrat_id character(36) NOT NULL,
    cataitm_id character varying(20) NOT NULL,
    placomalm_alm_id smallint NOT NULL,
    placomalm_stock_actual integer NOT NULL,
    placomalm_consumo_medio_mensual integer NOT NULL,
    placomalm_consumo_datajson text NOT NULL
);


--
-- Name: planillamessalida; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.planillamessalida (
    plamessal_id character(36) NOT NULL,
    plamessal_mes smallint NOT NULL,
    plamessal_anio smallint NOT NULL,
    plamessal_alm_id smallint NOT NULL,
    plamessal_estado smallint NOT NULL,
    plamessal_createuser character varying(40) NOT NULL,
    plamessal_createdate timestamp without time zone NOT NULL,
    plamessal_updateuser character varying(40) NOT NULL,
    plamessal_updatedate timestamp without time zone NOT NULL
);


--
-- Name: planillamessalidaitem; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.planillamessalidaitem (
    plamessal_id character(36) NOT NULL,
    plamessalitm_id integer NOT NULL,
    almcataitmalm_id smallint NOT NULL,
    cataitm_id character varying(20) NOT NULL,
    plamessalitm_ingalm_id_ref character(36) NOT NULL,
    plamessalitm_ingalmitm_id_ref smallint NOT NULL,
    plamessalitm_cantidad_saldo_mes_anterior integer NOT NULL,
    plamessalitm_cantidad_ingresos_mes integer NOT NULL,
    plamessalitm_cantidad_salida_transf integer NOT NULL,
    plamessalitm_lote integer NOT NULL,
    plamessalitm_fecha_exp integer NOT NULL,
    plamessalitm_costo_unitario integer NOT NULL,
    plamessalitm_cantidad_dia_1 integer NOT NULL,
    plamessalitm_cantidad_dia_2 integer NOT NULL,
    plamessalitm_cantidad_dia_3 integer NOT NULL,
    plamessalitm_cantidad_dia_4 integer NOT NULL,
    plamessalitm_cantidad_dia_5 integer NOT NULL,
    plamessalitm_cantidad_dia_6 integer NOT NULL,
    plamessalitm_cantidad_dia_7 integer NOT NULL,
    plamessalitm_cantidad_dia_8 integer NOT NULL,
    plamessalitm_cantidad_dia_9 integer NOT NULL,
    plamessalitm_cantidad_dia_10 integer NOT NULL,
    plamessalitm_cantidad_dia_11 integer NOT NULL,
    plamessalitm_cantidad_dia_12 integer NOT NULL,
    plamessalitm_cantidad_dia_13 integer NOT NULL,
    plamessalitm_cantidad_dia_14 integer NOT NULL,
    plamessalitm_cantidad_dia_15 integer NOT NULL,
    plamessalitm_cantidad_dia_16 integer NOT NULL,
    plamessalitm_cantidad_dia_17 integer NOT NULL,
    plamessalitm_cantidad_dia_18 integer NOT NULL,
    plamessalitm_cantidad_dia_19 integer NOT NULL,
    plamessalitm_cantidad_dia_20 integer NOT NULL,
    plamessalitm_cantidad_dia_21 integer NOT NULL,
    plamessalitm_cantidad_dia_22 integer NOT NULL,
    plamessalitm_cantidad_dia_23 integer NOT NULL,
    plamessalitm_cantidad_dia_24 integer NOT NULL,
    plamessalitm_cantidad_dia_25 integer NOT NULL,
    plamessalitm_cantidad_dia_26 integer NOT NULL,
    plamessalitm_cantidad_dia_27 integer NOT NULL,
    plamessalitm_cantidad_dia_28 integer NOT NULL,
    plamessalitm_cantidad_dia_29 integer NOT NULL,
    plamessalitm_cantidad_dia_30 integer NOT NULL,
    plamessalitm_cantidad_dia_31 integer NOT NULL
);


--
-- Name: planillamessalidanota; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.planillamessalidanota (
    plamessal_id character(36) NOT NULL,
    plamessalnot_id date NOT NULL,
    plamessalnot_explicacion text NOT NULL
);


--
-- Name: plaprosim_id; Type: SEQUENCE; Schema: msib; Owner: -
--

CREATE SEQUENCE msib.plaprosim_id
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plantilla_producto_simulador; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.plantilla_producto_simulador (
    plaprosim_id smallint DEFAULT nextval('msib.plaprosim_id'::regclass) NOT NULL,
    plaprosim_nombre character varying(100) NOT NULL,
    plaprosim_descripcion text NOT NULL,
    plaprosim_activo smallint NOT NULL
);


--
-- Name: plantilla_producto_simulador_item; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.plantilla_producto_simulador_item (
    plaprosim_id smallint NOT NULL,
    cataitm_id character varying(20) NOT NULL,
    plaprosimitm_activo smallint NOT NULL
);


--
-- Name: proveedor; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.proveedor (
    prv_id smallint NOT NULL,
    prv_nombre character varying(100) NOT NULL,
    prv_telefono_fijo character(20) NOT NULL,
    prv_telefono_movil character(20) NOT NULL,
    prv_direccion character varying(1024) NOT NULL,
    prv_activo smallint NOT NULL,
    prvtipprv_id integer NOT NULL
);


--
-- Name: rangodiaexpiracion; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.rangodiaexpiracion (
    ranexp_id smallint NOT NULL,
    ranexp_descripcion character varying(40) NOT NULL,
    ranexp_valor_dia smallint NOT NULL
);


--
-- Name: repositoriodigital; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.repositoriodigital (
    repdig_id character(36) NOT NULL,
    repdig_identificador_externo character varying(200) NOT NULL,
    repdig_nombre_externo character varying(40) NOT NULL,
    repdig_blobfile bytea NOT NULL,
    repdig_nombre_archivo character varying(60) NOT NULL,
    repdig_descripcion character varying(100) NOT NULL,
    repdig_activo smallint NOT NULL,
    repdig_createuser character varying(40) NOT NULL,
    repdig_createdate timestamp without time zone NOT NULL,
    repdig_updateuser character varying(40) NOT NULL,
    repdig_updatedate timestamp without time zone NOT NULL,
    repdig_extension_archivo character varying(4) NOT NULL,
    repdig_tipo_archivo character varying(30) NOT NULL,
    repdig_nombre character varying(80) NOT NULL,
    repdig_tamano_archivo integer NOT NULL,
    repdig_fecha_registro timestamp without time zone NOT NULL
);


--
-- Name: resumencostoinventario; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.resumencostoinventario (
    rescosinv_id character(36) NOT NULL,
    rescosinv_fecha date NOT NULL,
    rescosinv_costo_saldo_anterior numeric(11,2) NOT NULL,
    rescosinv_costo_ingresos numeric(11,2) NOT NULL,
    rescosinv_costo_salidas numeric(11,2) NOT NULL,
    rescosinv_costo_ajustes numeric(11,2) NOT NULL,
    rescosinv_costo_traspasos numeric(11,2) NOT NULL,
    almcataitmalm_id smallint NOT NULL,
    cataitm_id character varying(20) NOT NULL,
    almitmdisfuefin_id integer NOT NULL,
    rescosinv_cantidad_saldo_anterior integer NOT NULL,
    rescosinv_cantidad_ingresos integer NOT NULL,
    rescosinv_cantidad_salidas integer NOT NULL,
    rescosinv_cantidad_ajustes integer NOT NULL,
    rescosinv_cantidad_traspasos integer NOT NULL,
    rescosinv_cantidad_saldo integer NOT NULL
);


--
-- Name: secfunctionalityid; Type: SEQUENCE; Schema: msib; Owner: -
--

CREATE SEQUENCE msib.secfunctionalityid
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: secfunctionality; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.secfunctionality (
    secfunctionalityid bigint DEFAULT nextval('msib.secfunctionalityid'::regclass) NOT NULL,
    secfunctionalitykey character varying(100) NOT NULL,
    secfunctionalitydescription character varying(100) NOT NULL,
    secfunctionalitytype smallint NOT NULL,
    secparentfunctionalityid bigint,
    secfunctionalityactive boolean NOT NULL
);


--
-- Name: secfunctionalityrole; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.secfunctionalityrole (
    secfunctionalityid bigint NOT NULL,
    secroleid smallint NOT NULL
);


--
-- Name: secobject; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.secobject (
    secobjectname character varying(120) NOT NULL
);


--
-- Name: secobjectfunctionalities; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.secobjectfunctionalities (
    secobjectname character varying(120) NOT NULL,
    secfunctionalityid bigint NOT NULL
);


--
-- Name: secroleid; Type: SEQUENCE; Schema: msib; Owner: -
--

CREATE SEQUENCE msib.secroleid
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: secrole; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.secrole (
    secroleid smallint DEFAULT nextval('msib.secroleid'::regclass) NOT NULL,
    secrolename character varying(40) NOT NULL,
    secroledescription character varying(120) NOT NULL
);


--
-- Name: secuserid; Type: SEQUENCE; Schema: msib; Owner: -
--

CREATE SEQUENCE msib.secuserid
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: secuser; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.secuser (
    secuserid smallint DEFAULT nextval('msib.secuserid'::regclass) NOT NULL,
    secusername character varying(100) NOT NULL,
    secuserpassword character varying(100) NOT NULL,
    secuserper_id smallint NOT NULL,
    secuserstatus smallint NOT NULL,
    secuserisreset boolean NOT NULL,
    secuser_updateuser character varying(40) NOT NULL,
    secuser_updatedate date NOT NULL,
    secuser_namefill character varying(100) NOT NULL
);


--
-- Name: secuseralmacen; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.secuseralmacen (
    secuserid smallint NOT NULL,
    alm_id smallint NOT NULL
);


--
-- Name: secuseroficina; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.secuseroficina (
    secuserid smallint NOT NULL,
    ofi_id smallint NOT NULL
);


--
-- Name: secuserrole; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.secuserrole (
    secuserid smallint NOT NULL,
    secroleid smallint NOT NULL
);


--
-- Name: tablabasedata; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.tablabasedata (
    tabbasdat_id integer NOT NULL,
    tabbasgru_id smallint NOT NULL,
    tabbasdat_descripcion character varying(200) NOT NULL,
    tabbasdat_id_interno character varying(10) NOT NULL,
    tabbasdat_activo smallint NOT NULL
);


--
-- Name: tablabasegrupo; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.tablabasegrupo (
    tabbasgru_id smallint NOT NULL,
    tabbasgru_descripcion character varying(200) NOT NULL,
    tabbasgru_nombre_tabla character varying(60) NOT NULL
);


--
-- Name: tipo_dato_tecnico; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.tipo_dato_tecnico (
    tdt_id integer NOT NULL,
    tdt_nombre character varying(40) NOT NULL,
    tdt_datatype character varying(40) NOT NULL,
    tdt_descripcion character varying(80) NOT NULL,
    tdt_activo smallint NOT NULL
);


--
-- Name: tipodocumento; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.tipodocumento (
    tipdoc_id smallint NOT NULL,
    tipdoc_nombre character varying(100) NOT NULL,
    tipdoc_prefijo character varying(5) NOT NULL,
    tipdoccatdoc_id integer NOT NULL,
    tipdoc_nro_documento integer NOT NULL,
    tipdoc_activo smallint NOT NULL
);


--
-- Name: usercustomizations; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.usercustomizations (
    usercustomizationsid integer NOT NULL,
    usercustomizationskey character varying(200) NOT NULL,
    usercustomizationsvalue text NOT NULL
);


--
-- Name: wwpentityid; Type: SEQUENCE; Schema: msib; Owner: -
--

CREATE SEQUENCE msib.wwpentityid
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wwp_entity; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.wwp_entity (
    wwpentityid bigint DEFAULT nextval('msib.wwpentityid'::regclass) NOT NULL,
    wwpentityname character varying(100) NOT NULL
);


--
-- Name: wwpmailid; Type: SEQUENCE; Schema: msib; Owner: -
--

CREATE SEQUENCE msib.wwpmailid
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wwp_mail; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.wwp_mail (
    wwpmailid bigint DEFAULT nextval('msib.wwpmailid'::regclass) NOT NULL,
    wwpmailsubject character varying(80) NOT NULL,
    wwpmailbody text NOT NULL,
    wwpmailto text,
    wwpmailcc text,
    wwpmailbcc text,
    wwpmailsenderaddress text NOT NULL,
    wwpmailsendername text NOT NULL,
    wwpmailstatus smallint NOT NULL,
    wwpmailcreated timestamp without time zone NOT NULL,
    wwpmailscheduled timestamp without time zone NOT NULL,
    wwpmailprocessed timestamp without time zone,
    wwpmaildetail text,
    wwpnotificationid bigint
);


--
-- Name: wwp_mailattachments; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.wwp_mailattachments (
    wwpmailid bigint NOT NULL,
    wwpmailattachmentname character varying(40) NOT NULL,
    wwpmailattachmentfile text NOT NULL
);


--
-- Name: wwp_mailtemplate; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.wwp_mailtemplate (
    wwpmailtemplatename character varying(40) NOT NULL,
    wwpmailtemplatedescription character varying(100) NOT NULL,
    wwpmailtemplatesubject character varying(80) NOT NULL,
    wwpmailtemplatebody text NOT NULL,
    wwpmailtemplatesenderaddress text NOT NULL,
    wwpmailtemplatesendername text NOT NULL
);


--
-- Name: wwpnotificationid; Type: SEQUENCE; Schema: msib; Owner: -
--

CREATE SEQUENCE msib.wwpnotificationid
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wwp_notification; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.wwp_notification (
    wwpnotificationid bigint DEFAULT nextval('msib.wwpnotificationid'::regclass) NOT NULL,
    wwpnotificationdefinitionid bigint NOT NULL,
    wwpnotificationcreated timestamp without time zone NOT NULL,
    wwpnotificationicon character varying(100) NOT NULL,
    wwpnotificationtitle character varying(200) NOT NULL,
    wwpnotificationshortdescription character varying(200) NOT NULL,
    wwpnotificationlink character varying(1000) NOT NULL,
    wwpnotificationisread boolean NOT NULL,
    wwpuserextendedid character(40),
    wwpnotificationmetadata text
);


--
-- Name: wwpnotificationdefinitionid; Type: SEQUENCE; Schema: msib; Owner: -
--

CREATE SEQUENCE msib.wwpnotificationdefinitionid
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wwp_notificationdefinition; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.wwp_notificationdefinition (
    wwpnotificationdefinitionid bigint DEFAULT nextval('msib.wwpnotificationdefinitionid'::regclass) NOT NULL,
    wwpnotificationdefinitionname character varying(100) NOT NULL,
    wwpnotificationdefinitionappliesto smallint NOT NULL,
    wwpnotificationdefinitionallowusersubscriptio boolean NOT NULL,
    wwpnotificationdefinitiondescription character varying(200) NOT NULL,
    wwpnotificationdefinitionicon character varying(40) NOT NULL,
    wwpnotificationdefinitiontitle character varying(200) NOT NULL,
    wwpnotificationdefinitionshortdescription character varying(200) NOT NULL,
    wwpnotificationdefinitionlongdescription character varying(1000) NOT NULL,
    wwpnotificationdefinitionlink character varying(1000) NOT NULL,
    wwpentityid bigint NOT NULL,
    wwpnotificationdefinitionsecfuncionality character varying(200) NOT NULL
);


--
-- Name: wwp_parameter; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.wwp_parameter (
    wwpparameterkey character varying(300) NOT NULL,
    wwpparametercategory character varying(200) NOT NULL,
    wwpparameterdescription character varying(200) NOT NULL,
    wwpparametervalue text NOT NULL,
    wwpparameterdisabledelete boolean NOT NULL
);


--
-- Name: wwpsmsid; Type: SEQUENCE; Schema: msib; Owner: -
--

CREATE SEQUENCE msib.wwpsmsid
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wwp_sms; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.wwp_sms (
    wwpsmsid bigint DEFAULT nextval('msib.wwpsmsid'::regclass) NOT NULL,
    wwpsmsmessage text NOT NULL,
    wwpsmssendernumber text NOT NULL,
    wwpsmsrecipientnumbers text NOT NULL,
    wwpsmsstatus smallint NOT NULL,
    wwpsmscreated timestamp without time zone NOT NULL,
    wwpsmsscheduled timestamp without time zone NOT NULL,
    wwpsmsprocessed timestamp without time zone,
    wwpsmsdetail text,
    wwpnotificationid bigint
);


--
-- Name: wwpsubscriptionid; Type: SEQUENCE; Schema: msib; Owner: -
--

CREATE SEQUENCE msib.wwpsubscriptionid
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wwp_subscription; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.wwp_subscription (
    wwpsubscriptionid bigint DEFAULT nextval('msib.wwpsubscriptionid'::regclass) NOT NULL,
    wwpnotificationdefinitionid bigint NOT NULL,
    wwpuserextendedid character(40),
    wwpsubscriptionentityrecordid character varying(2000) NOT NULL,
    wwpsubscriptionentityrecorddescription character varying(200) NOT NULL,
    wwpsubscriptionroleid character(40),
    wwpsubscriptionsubscribed boolean NOT NULL
);


--
-- Name: wwp_userextended; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.wwp_userextended (
    wwpuserextendedid character(40) NOT NULL,
    wwpuserextendedphoto bytea NOT NULL,
    wwpuserextendedphoto_gxi character varying(2048),
    wwpuserextendedname character varying(100) NOT NULL,
    wwpuserextendedfullname character varying(100) NOT NULL,
    wwpuserextendedphone character(20) NOT NULL,
    wwpuserextendedemail character varying(100) NOT NULL,
    wwpuserextendedemainotif boolean NOT NULL,
    wwpuserextendedsmsnotif boolean NOT NULL,
    wwpuserextendedmobilenotif boolean NOT NULL,
    wwpuserextendeddesktopnotif boolean NOT NULL,
    wwpuserextendeddeleted boolean NOT NULL,
    wwpuserextendeddeletedin timestamp without time zone
);


--
-- Name: wwp_webclient; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.wwp_webclient (
    wwpwebclientid character(100) NOT NULL,
    wwpwebclientbrowserid smallint NOT NULL,
    wwpwebclientbrowserversion text NOT NULL,
    wwpwebclientfirstregistered timestamp without time zone NOT NULL,
    wwpwebclientlastregistered timestamp without time zone NOT NULL,
    wwpuserextendedid character(40)
);


--
-- Name: wwpwebnotificationid; Type: SEQUENCE; Schema: msib; Owner: -
--

CREATE SEQUENCE msib.wwpwebnotificationid
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wwp_webnotification; Type: TABLE; Schema: msib; Owner: -
--

CREATE TABLE msib.wwp_webnotification (
    wwpwebnotificationid bigint DEFAULT nextval('msib.wwpwebnotificationid'::regclass) NOT NULL,
    wwpwebnotificationtitle character varying(40) NOT NULL,
    wwpnotificationid bigint,
    wwpwebnotificationtext character varying(120) NOT NULL,
    wwpwebnotificationicon character varying(255) NOT NULL,
    wwpwebnotificationclientid text NOT NULL,
    wwpwebnotificationstatus smallint NOT NULL,
    wwpwebnotificationcreated timestamp without time zone NOT NULL,
    wwpwebnotificationscheduled timestamp without time zone NOT NULL,
    wwpwebnotificationprocessed timestamp without time zone NOT NULL,
    wwpwebnotificationread timestamp without time zone,
    wwpwebnotificationdetail text,
    wwpwebnotificationreceived boolean
);


--
-- Name: actasactivofijo actasactivofijo_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.actasactivofijo
    ADD CONSTRAINT actasactivofijo_pkey PRIMARY KEY (actaaf_id);


--
-- Name: actasactivofijoaf actasactivofijoaf_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.actasactivofijoaf
    ADD CONSTRAINT actasactivofijoaf_pkey PRIMARY KEY (actaaf_id, actfij_id);


--
-- Name: activofijo activofijo_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.activofijo
    ADD CONSTRAINT activofijo_pkey PRIMARY KEY (actfij_id);


--
-- Name: activofijohistorialestado activofijohistorialestado_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.activofijohistorialestado
    ADD CONSTRAINT activofijohistorialestado_pkey PRIMARY KEY (actfijhis_id);


--
-- Name: almacen almacen_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.almacen
    ADD CONSTRAINT almacen_pkey PRIMARY KEY (alm_id);


--
-- Name: almacencatalogoitem almacencatalogoitem_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.almacencatalogoitem
    ADD CONSTRAINT almacencatalogoitem_pkey PRIMARY KEY (almcataitmalm_id, cataitm_id);


--
-- Name: asignacionpersonal asignacionpersonal_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.asignacionpersonal
    ADD CONSTRAINT asignacionpersonal_pkey PRIMARY KEY (asgper_id);


--
-- Name: autorizacionanulacion autorizacionanulacion_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.autorizacionanulacion
    ADD CONSTRAINT autorizacionanulacion_pkey PRIMARY KEY (autanu_id);


--
-- Name: cargo cargo_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.cargo
    ADD CONSTRAINT cargo_pkey PRIMARY KEY (car_id);


--
-- Name: catalogoitem catalogoitem_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.catalogoitem
    ADD CONSTRAINT catalogoitem_pkey PRIMARY KEY (cataitm_id);


--
-- Name: catalogoitemdigital catalogoitemdigital_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.catalogoitemdigital
    ADD CONSTRAINT catalogoitemdigital_pkey PRIMARY KEY (cataitm_id, cataitmdig_repdig_id);


--
-- Name: categoriaitem categoriaitem_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.categoriaitem
    ADD CONSTRAINT categoriaitem_pkey PRIMARY KEY (catitm_id);


--
-- Name: centrocosto centrocosto_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.centrocosto
    ADD CONSTRAINT centrocosto_pkey PRIMARY KEY (ccos_id);


--
-- Name: familiaitem familiaitem_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.familiaitem
    ADD CONSTRAINT familiaitem_pkey PRIMARY KEY (famitm_id);


--
-- Name: flujoaprobaciondocumento flujoaprobaciondocumento_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.flujoaprobaciondocumento
    ADD CONSTRAINT flujoaprobaciondocumento_pkey PRIMARY KEY (fluaprdoc_id);


--
-- Name: grupoitem grupoitem_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.grupoitem
    ADD CONSTRAINT grupoitem_pkey PRIMARY KEY (gruitm_id);


--
-- Name: ingresoalmacen ingresoalmacen_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.ingresoalmacen
    ADD CONSTRAINT ingresoalmacen_pkey PRIMARY KEY (ingalm_id);


--
-- Name: ingresoalmacenitem ingresoalmacenitem_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.ingresoalmacenitem
    ADD CONSTRAINT ingresoalmacenitem_pkey PRIMARY KEY (ingalm_id, ingalmitm_id);


--
-- Name: inventariofisico inventariofisico_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.inventariofisico
    ADD CONSTRAINT inventariofisico_pkey PRIMARY KEY (invfis_id);


--
-- Name: inventariofisicoitems inventariofisicoitems_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.inventariofisicoitems
    ADD CONSTRAINT inventariofisicoitems_pkey PRIMARY KEY (invfis_id, invfisitm_id);


--
-- Name: kardexconsolidadomensual kardexconsolidadomensual_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.kardexconsolidadomensual
    ADD CONSTRAINT kardexconsolidadomensual_pkey PRIMARY KEY (karconmes_id);


--
-- Name: kardexmovimientomensual kardexmovimientomensual_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.kardexmovimientomensual
    ADD CONSTRAINT kardexmovimientomensual_pkey PRIMARY KEY (karmovmes_id);


--
-- Name: lineatelefonia lineatelefonia_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.lineatelefonia
    ADD CONSTRAINT lineatelefonia_pkey PRIMARY KEY (lintel_id);


--
-- Name: logcierremesinventario logcierremesinventario_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.logcierremesinventario
    ADD CONSTRAINT logcierremesinventario_pkey PRIMARY KEY (logcieinv_mes, logcieinv_anio);


--
-- Name: logcierremesinventarioalmacen logcierremesinventarioalmacen_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.logcierremesinventarioalmacen
    ADD CONSTRAINT logcierremesinventarioalmacen_pkey PRIMARY KEY (logcieinv_anio, logcieinv_mes, alm_id);


--
-- Name: logtokenapicrs logtokenapicrs_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.logtokenapicrs
    ADD CONSTRAINT logtokenapicrs_pkey PRIMARY KEY (logtokcrs_id);


--
-- Name: menuitem menuitem_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.menuitem
    ADD CONSTRAINT menuitem_pkey PRIMARY KEY (menuitemid);


--
-- Name: numerofolioalmacen numerofolioalmacen_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.numerofolioalmacen
    ADD CONSTRAINT numerofolioalmacen_pkey PRIMARY KEY (numfolalm_mes, numfolalm_anio, alm_id);


--
-- Name: oficinas oficinas_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.oficinas
    ADD CONSTRAINT oficinas_pkey PRIMARY KEY (ofi_id);


--
-- Name: parametroconfiguracion parametroconfiguracion_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.parametroconfiguracion
    ADD CONSTRAINT parametroconfiguracion_pkey PRIMARY KEY (parcfg_id);


--
-- Name: parametroconfiguracionitem parametroconfiguracionitem_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.parametroconfiguracionitem
    ADD CONSTRAINT parametroconfiguracionitem_pkey PRIMARY KEY (parcfg_id, parcfgitm_id);


--
-- Name: personal personal_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.personal
    ADD CONSTRAINT personal_pkey PRIMARY KEY (per_id);


--
-- Name: planificar_compra_ratio_item_almacen planificar_compra_ratio_item_almacen_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.planificar_compra_ratio_item_almacen
    ADD CONSTRAINT planificar_compra_ratio_item_almacen_pkey PRIMARY KEY (placomrat_id, cataitm_id, placomalm_alm_id);


--
-- Name: planificar_compra_ratio_item planificar_compra_ratio_item_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.planificar_compra_ratio_item
    ADD CONSTRAINT planificar_compra_ratio_item_pkey PRIMARY KEY (placomrat_id, cataitm_id);


--
-- Name: planificar_compra_ratio planificar_compra_ratio_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.planificar_compra_ratio
    ADD CONSTRAINT planificar_compra_ratio_pkey PRIMARY KEY (placomrat_id);


--
-- Name: planillamessalida planillamessalida_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.planillamessalida
    ADD CONSTRAINT planillamessalida_pkey PRIMARY KEY (plamessal_id);


--
-- Name: planillamessalidaitem planillamessalidaitem_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.planillamessalidaitem
    ADD CONSTRAINT planillamessalidaitem_pkey PRIMARY KEY (plamessal_id, plamessalitm_id);


--
-- Name: planillamessalidanota planillamessalidanota_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.planillamessalidanota
    ADD CONSTRAINT planillamessalidanota_pkey PRIMARY KEY (plamessal_id, plamessalnot_id);


--
-- Name: plantilla_producto_simulador_item plantilla_producto_simulador_item_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.plantilla_producto_simulador_item
    ADD CONSTRAINT plantilla_producto_simulador_item_pkey PRIMARY KEY (plaprosim_id, cataitm_id);


--
-- Name: plantilla_producto_simulador plantilla_producto_simulador_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.plantilla_producto_simulador
    ADD CONSTRAINT plantilla_producto_simulador_pkey PRIMARY KEY (plaprosim_id);


--
-- Name: proveedor proveedor_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.proveedor
    ADD CONSTRAINT proveedor_pkey PRIMARY KEY (prv_id);


--
-- Name: rangodiaexpiracion rangodiaexpiracion_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.rangodiaexpiracion
    ADD CONSTRAINT rangodiaexpiracion_pkey PRIMARY KEY (ranexp_id);


--
-- Name: repositoriodigital repositoriodigital_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.repositoriodigital
    ADD CONSTRAINT repositoriodigital_pkey PRIMARY KEY (repdig_id);


--
-- Name: resumencostoinventario resumencostoinventario_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.resumencostoinventario
    ADD CONSTRAINT resumencostoinventario_pkey PRIMARY KEY (rescosinv_id);


--
-- Name: salidaalmacen salidaalmacen_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.salidaalmacen
    ADD CONSTRAINT salidaalmacen_pkey PRIMARY KEY (salalm_id);


--
-- Name: salidaalmacenitem salidaalmacenitem_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.salidaalmacenitem
    ADD CONSTRAINT salidaalmacenitem_pkey PRIMARY KEY (salalm_id, salalmitm_id);


--
-- Name: secfunctionality secfunctionality_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.secfunctionality
    ADD CONSTRAINT secfunctionality_pkey PRIMARY KEY (secfunctionalityid);


--
-- Name: secfunctionalityrole secfunctionalityrole_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.secfunctionalityrole
    ADD CONSTRAINT secfunctionalityrole_pkey PRIMARY KEY (secfunctionalityid, secroleid);


--
-- Name: secobject secobject_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.secobject
    ADD CONSTRAINT secobject_pkey PRIMARY KEY (secobjectname);


--
-- Name: secobjectfunctionalities secobjectfunctionalities_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.secobjectfunctionalities
    ADD CONSTRAINT secobjectfunctionalities_pkey PRIMARY KEY (secobjectname, secfunctionalityid);


--
-- Name: secrole secrole_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.secrole
    ADD CONSTRAINT secrole_pkey PRIMARY KEY (secroleid);


--
-- Name: secuser secuser_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.secuser
    ADD CONSTRAINT secuser_pkey PRIMARY KEY (secuserid);


--
-- Name: secuseralmacen secuseralmacen_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.secuseralmacen
    ADD CONSTRAINT secuseralmacen_pkey PRIMARY KEY (secuserid, alm_id);


--
-- Name: secuseroficina secuseroficina_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.secuseroficina
    ADD CONSTRAINT secuseroficina_pkey PRIMARY KEY (secuserid, ofi_id);


--
-- Name: secuserrole secuserrole_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.secuserrole
    ADD CONSTRAINT secuserrole_pkey PRIMARY KEY (secuserid, secroleid);


--
-- Name: tablabasedata tablabasedata_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.tablabasedata
    ADD CONSTRAINT tablabasedata_pkey PRIMARY KEY (tabbasdat_id);


--
-- Name: tablabasegrupo tablabasegrupo_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.tablabasegrupo
    ADD CONSTRAINT tablabasegrupo_pkey PRIMARY KEY (tabbasgru_id);


--
-- Name: tipo_dato_tecnico tipo_dato_tecnico_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.tipo_dato_tecnico
    ADD CONSTRAINT tipo_dato_tecnico_pkey PRIMARY KEY (tdt_id);


--
-- Name: tipodocumento tipodocumento_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.tipodocumento
    ADD CONSTRAINT tipodocumento_pkey PRIMARY KEY (tipdoc_id);


--
-- Name: usercustomizations usercustomizations_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.usercustomizations
    ADD CONSTRAINT usercustomizations_pkey PRIMARY KEY (usercustomizationsid, usercustomizationskey);


--
-- Name: wwp_entity wwp_entity_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.wwp_entity
    ADD CONSTRAINT wwp_entity_pkey PRIMARY KEY (wwpentityid);


--
-- Name: wwp_mail wwp_mail_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.wwp_mail
    ADD CONSTRAINT wwp_mail_pkey PRIMARY KEY (wwpmailid);


--
-- Name: wwp_mailattachments wwp_mailattachments_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.wwp_mailattachments
    ADD CONSTRAINT wwp_mailattachments_pkey PRIMARY KEY (wwpmailid, wwpmailattachmentname);


--
-- Name: wwp_mailtemplate wwp_mailtemplate_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.wwp_mailtemplate
    ADD CONSTRAINT wwp_mailtemplate_pkey PRIMARY KEY (wwpmailtemplatename);


--
-- Name: wwp_notification wwp_notification_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.wwp_notification
    ADD CONSTRAINT wwp_notification_pkey PRIMARY KEY (wwpnotificationid);


--
-- Name: wwp_notificationdefinition wwp_notificationdefinition_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.wwp_notificationdefinition
    ADD CONSTRAINT wwp_notificationdefinition_pkey PRIMARY KEY (wwpnotificationdefinitionid);


--
-- Name: wwp_parameter wwp_parameter_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.wwp_parameter
    ADD CONSTRAINT wwp_parameter_pkey PRIMARY KEY (wwpparameterkey);


--
-- Name: wwp_sms wwp_sms_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.wwp_sms
    ADD CONSTRAINT wwp_sms_pkey PRIMARY KEY (wwpsmsid);


--
-- Name: wwp_subscription wwp_subscription_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.wwp_subscription
    ADD CONSTRAINT wwp_subscription_pkey PRIMARY KEY (wwpsubscriptionid);


--
-- Name: wwp_userextended wwp_userextended_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.wwp_userextended
    ADD CONSTRAINT wwp_userextended_pkey PRIMARY KEY (wwpuserextendedid);


--
-- Name: wwp_webclient wwp_webclient_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.wwp_webclient
    ADD CONSTRAINT wwp_webclient_pkey PRIMARY KEY (wwpwebclientid);


--
-- Name: wwp_webnotification wwp_webnotification_pkey; Type: CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.wwp_webnotification
    ADD CONSTRAINT wwp_webnotification_pkey PRIMARY KEY (wwpwebnotificationid);


--
-- Name: iactasactivofijo1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iactasactivofijo1 ON msib.actasactivofijo USING btree (actaaf_cusde_id);


--
-- Name: iactasactivofijo2; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iactasactivofijo2 ON msib.actasactivofijo USING btree (actaaf_cusa_id);


--
-- Name: iactasactivofijo3; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iactasactivofijo3 ON msib.actasactivofijo USING btree (actaaf_respon_id);


--
-- Name: iactasactivofijo4; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iactasactivofijo4 ON msib.actasactivofijo USING btree (tipdoc_id);


--
-- Name: iactasactivofijo5; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iactasactivofijo5 ON msib.actasactivofijo USING btree (actaaf_estadoacta_id);


--
-- Name: iactasactivofijoaf1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iactasactivofijoaf1 ON msib.actasactivofijoaf USING btree (actfij_id);


--
-- Name: iactasactivofijoaf3; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iactasactivofijoaf3 ON msib.actasactivofijoaf USING btree (actaaf_af_conservacion_id);


--
-- Name: iactasactivofijoaf4; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iactasactivofijoaf4 ON msib.actasactivofijoaf USING btree (actaaf_af_ofi_id);


--
-- Name: iactivofijo1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iactivofijo1 ON msib.activofijo USING btree (prv_id);


--
-- Name: iactivofijo2; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iactivofijo2 ON msib.activofijo USING btree (catitm_id);


--
-- Name: iactivofijo3; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iactivofijo3 ON msib.activofijo USING btree (ofi_id);


--
-- Name: iactivofijo4; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iactivofijo4 ON msib.activofijo USING btree (actfij_cus_id);


--
-- Name: iactivofijo5; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iactivofijo5 ON msib.activofijo USING btree (actfij_estado_custodia_id);


--
-- Name: iactivofijohistorialestado1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iactivofijohistorialestado1 ON msib.activofijohistorialestado USING btree (actfij_id);


--
-- Name: iactivofijohistorialestado2; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iactivofijohistorialestado2 ON msib.activofijohistorialestado USING btree (actfijhis_estado_activo_id);


--
-- Name: ialmacen1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX ialmacen1 ON msib.almacen USING btree (ofi_id);


--
-- Name: ialmacencatalogoitem1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX ialmacencatalogoitem1 ON msib.almacencatalogoitem USING btree (cataitm_id);


--
-- Name: iasignacionpersonal1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iasignacionpersonal1 ON msib.asignacionpersonal USING btree (asgperper_id);


--
-- Name: iasignacionpersonal2; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iasignacionpersonal2 ON msib.asignacionpersonal USING btree (asgpercar_id);


--
-- Name: iautorizacionanulacion1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iautorizacionanulacion1 ON msib.autorizacionanulacion USING btree (autanuper_id);


--
-- Name: iautorizacionanulacion2; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iautorizacionanulacion2 ON msib.autorizacionanulacion USING btree (ofi_id);


--
-- Name: iautorizacionanulacion3; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iautorizacionanulacion3 ON msib.autorizacionanulacion USING btree (solanuper_id);


--
-- Name: iautorizacionanulacion4; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iautorizacionanulacion4 ON msib.autorizacionanulacion USING btree (autanu_estado_id);


--
-- Name: icatalogoitem1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX icatalogoitem1 ON msib.catalogoitem USING btree (catitm_id);


--
-- Name: icatalogoitem2; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX icatalogoitem2 ON msib.catalogoitem USING btree (cataitmunimed_id);


--
-- Name: icategoriaitem1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX icategoriaitem1 ON msib.categoriaitem USING btree (gruitm_id);


--
-- Name: icentrocosto1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX icentrocosto1 ON msib.centrocosto USING btree (ccosgru_id);


--
-- Name: igrupoitem1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX igrupoitem1 ON msib.grupoitem USING btree (famitm_id);


--
-- Name: iingresoalmacen1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iingresoalmacen1 ON msib.ingresoalmacen USING btree (ingalmalmori_id);


--
-- Name: iingresoalmacen2; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iingresoalmacen2 ON msib.ingresoalmacen USING btree (ingalmalmdes_id);


--
-- Name: iingresoalmacen3; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iingresoalmacen3 ON msib.ingresoalmacen USING btree (ingalmalm_id);


--
-- Name: iingresoalmacen4; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iingresoalmacen4 ON msib.ingresoalmacen USING btree (ingalmprv_id);


--
-- Name: iingresoalmacen5; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iingresoalmacen5 ON msib.ingresoalmacen USING btree (ingalmasgper_id);


--
-- Name: iingresoalmacen6; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iingresoalmacen6 ON msib.ingresoalmacen USING btree (ingalmtipdoc_id);


--
-- Name: iingresoalmacen7; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iingresoalmacen7 ON msib.ingresoalmacen USING btree (ingalm_estado_id);


--
-- Name: iingresoalmacen8; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iingresoalmacen8 ON msib.ingresoalmacen USING btree (ingalmfuefin_id);


--
-- Name: iingresoalmacenitem1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iingresoalmacenitem1 ON msib.ingresoalmacenitem USING btree (almcataitmalm_id, cataitm_id);


--
-- Name: iingresoalmacenitem3; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iingresoalmacenitem3 ON msib.ingresoalmacenitem USING btree (ingalmitmfuefin_id);


--
-- Name: iinventariofisico1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iinventariofisico1 ON msib.inventariofisico USING btree (invfisalm_id);


--
-- Name: iinventariofisicoitems1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iinventariofisicoitems1 ON msib.inventariofisicoitems USING btree (almitmdisfuefin_id);


--
-- Name: iinventariofisicoitems2; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iinventariofisicoitems2 ON msib.inventariofisicoitems USING btree (almcataitmalm_id, cataitm_id);


--
-- Name: ikardexconsolidadomensual1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX ikardexconsolidadomensual1 ON msib.kardexconsolidadomensual USING btree (almcataitmalm_id, cataitm_id);


--
-- Name: ikardexconsolidadomensual2; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX ikardexconsolidadomensual2 ON msib.kardexconsolidadomensual USING btree (almitmdisfuefin_id);


--
-- Name: ikardexmovimientomensual1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX ikardexmovimientomensual1 ON msib.kardexmovimientomensual USING btree (almcataitmalm_id, cataitm_id);


--
-- Name: ilineatelefonia1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX ilineatelefonia1 ON msib.lineatelefonia USING btree (lintel_estadoid);


--
-- Name: ilineatelefonia2; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX ilineatelefonia2 ON msib.lineatelefonia USING btree (lintel_ofi_id);


--
-- Name: ilineatelefonia3; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX ilineatelefonia3 ON msib.lineatelefonia USING btree (actfij_id);


--
-- Name: ilogcierremesinventarioalmacen1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX ilogcierremesinventarioalmacen1 ON msib.logcierremesinventarioalmacen USING btree (alm_id);


--
-- Name: ilogcierremesinventarioalmacen2; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX ilogcierremesinventarioalmacen2 ON msib.logcierremesinventarioalmacen USING btree (logcieinv_mes, logcieinv_anio);


--
-- Name: imenuitem1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX imenuitem1 ON msib.menuitem USING btree (menuitemfatherid);


--
-- Name: imenuitem2; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX imenuitem2 ON msib.menuitem USING btree (secfunctionalityid);


--
-- Name: inumerofolioalmacen1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX inumerofolioalmacen1 ON msib.numerofolioalmacen USING btree (alm_id);


--
-- Name: ioficinas1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX ioficinas1 ON msib.oficinas USING btree (ofican_id);


--
-- Name: ioficinas2; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX ioficinas2 ON msib.oficinas USING btree (ccos_id);


--
-- Name: iplanificar_compra_ratiocataitm_1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iplanificar_compra_ratiocataitm_1 ON msib.planificar_compra_ratio_item USING btree (cataitm_id);


--
-- Name: iplanificar_compra_ratioitemalmacen1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iplanificar_compra_ratioitemalmacen1 ON msib.planificar_compra_ratio_item_almacen USING btree (placomalm_alm_id);


--
-- Name: iplanillamessalida1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iplanillamessalida1 ON msib.planillamessalida USING btree (plamessal_alm_id);


--
-- Name: iplanillamessalidaitem1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iplanillamessalidaitem1 ON msib.planillamessalidaitem USING btree (almcataitmalm_id, cataitm_id);


--
-- Name: iplantilla_producto_simuladoritem1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iplantilla_producto_simuladoritem1 ON msib.plantilla_producto_simulador_item USING btree (cataitm_id);


--
-- Name: iproveedor1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iproveedor1 ON msib.proveedor USING btree (prvtipprv_id);


--
-- Name: iresumencostoinventario1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iresumencostoinventario1 ON msib.resumencostoinventario USING btree (almitmdisfuefin_id);


--
-- Name: iresumencostoinventario2; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iresumencostoinventario2 ON msib.resumencostoinventario USING btree (almcataitmalm_id, cataitm_id);


--
-- Name: isalidaalmacen1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX isalidaalmacen1 ON msib.salidaalmacen USING btree (salalmalmori_id);


--
-- Name: isalidaalmacen2; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX isalidaalmacen2 ON msib.salidaalmacen USING btree (salalmalmdes_id);


--
-- Name: isalidaalmacen3; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX isalidaalmacen3 ON msib.salidaalmacen USING btree (salalmalm_id);


--
-- Name: isalidaalmacen4; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX isalidaalmacen4 ON msib.salidaalmacen USING btree (salalmprv_id);


--
-- Name: isalidaalmacen5; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX isalidaalmacen5 ON msib.salidaalmacen USING btree (salalmasgper_id);


--
-- Name: isalidaalmacen6; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX isalidaalmacen6 ON msib.salidaalmacen USING btree (salalmtipdoc_id);


--
-- Name: isalidaalmacen7; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX isalidaalmacen7 ON msib.salidaalmacen USING btree (salalm_estado_id);


--
-- Name: isalidaalmacen8; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX isalidaalmacen8 ON msib.salidaalmacen USING btree (salalm_estadotrans_id);


--
-- Name: isalidaalmacen9; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX isalidaalmacen9 ON msib.salidaalmacen USING btree (salalmfuefin_id);


--
-- Name: isalidaalmacenitem1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX isalidaalmacenitem1 ON msib.salidaalmacenitem USING btree (almcataitmalm_id, cataitm_id);


--
-- Name: isalidaalmacenitem3; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX isalidaalmacenitem3 ON msib.salidaalmacenitem USING btree (salalmitmfuefin_id);


--
-- Name: isecfunctionality1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX isecfunctionality1 ON msib.secfunctionality USING btree (secparentfunctionalityid);


--
-- Name: isecfunctionalityrol2; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX isecfunctionalityrol2 ON msib.secfunctionalityrole USING btree (secroleid);


--
-- Name: isecobjectfunctionalities1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX isecobjectfunctionalities1 ON msib.secobjectfunctionalities USING btree (secfunctionalityid);


--
-- Name: isecuseralmacen1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX isecuseralmacen1 ON msib.secuseralmacen USING btree (alm_id);


--
-- Name: isecuseroficina1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX isecuseroficina1 ON msib.secuseroficina USING btree (ofi_id);


--
-- Name: isecuserrole1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX isecuserrole1 ON msib.secuserrole USING btree (secroleid);


--
-- Name: itablabasedata1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX itablabasedata1 ON msib.tablabasedata USING btree (tabbasgru_id);


--
-- Name: itipodocumento1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX itipodocumento1 ON msib.tipodocumento USING btree (tipdoccatdoc_id);


--
-- Name: iwwp_mail1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iwwp_mail1 ON msib.wwp_mail USING btree (wwpnotificationid);


--
-- Name: iwwp_notification1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iwwp_notification1 ON msib.wwp_notification USING btree (wwpuserextendedid);


--
-- Name: iwwp_notification2; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iwwp_notification2 ON msib.wwp_notification USING btree (wwpnotificationdefinitionid);


--
-- Name: iwwp_notificationdefinition1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iwwp_notificationdefinition1 ON msib.wwp_notificationdefinition USING btree (wwpentityid);


--
-- Name: iwwp_sms1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iwwp_sms1 ON msib.wwp_sms USING btree (wwpnotificationid);


--
-- Name: iwwp_subscription1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iwwp_subscription1 ON msib.wwp_subscription USING btree (wwpuserextendedid);


--
-- Name: iwwp_subscription2; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iwwp_subscription2 ON msib.wwp_subscription USING btree (wwpnotificationdefinitionid);


--
-- Name: iwwp_webclient1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iwwp_webclient1 ON msib.wwp_webclient USING btree (wwpuserextendedid);


--
-- Name: iwwp_webnotification1; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX iwwp_webnotification1 ON msib.wwp_webnotification USING btree (wwpnotificationid);


--
-- Name: ukardexmovimientomensual; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX ukardexmovimientomensual ON msib.kardexmovimientomensual USING btree (karmovmes_anio, karmovmes_mes);


--
-- Name: urangodiaexpiracion; Type: INDEX; Schema: msib; Owner: -
--

CREATE UNIQUE INDEX urangodiaexpiracion ON msib.rangodiaexpiracion USING btree (ranexp_valor_dia);


--
-- Name: usecfunctionality; Type: INDEX; Schema: msib; Owner: -
--

CREATE UNIQUE INDEX usecfunctionality ON msib.secfunctionality USING btree (secfunctionalitykey);


--
-- Name: usecuser; Type: INDEX; Schema: msib; Owner: -
--

CREATE UNIQUE INDEX usecuser ON msib.secuser USING btree (secusername);


--
-- Name: utablabasegrupo; Type: INDEX; Schema: msib; Owner: -
--

CREATE UNIQUE INDEX utablabasegrupo ON msib.tablabasegrupo USING btree (tabbasgru_nombre_tabla);


--
-- Name: wwp_notificationcreateddate; Type: INDEX; Schema: msib; Owner: -
--

CREATE INDEX wwp_notificationcreateddate ON msib.wwp_notification USING btree (wwpnotificationcreated DESC);


--
-- Name: actasactivofijo iactasactivofijo1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.actasactivofijo
    ADD CONSTRAINT iactasactivofijo1 FOREIGN KEY (actaaf_cusde_id) REFERENCES msib.personal(per_id);


--
-- Name: actasactivofijo iactasactivofijo2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.actasactivofijo
    ADD CONSTRAINT iactasactivofijo2 FOREIGN KEY (actaaf_cusa_id) REFERENCES msib.personal(per_id);


--
-- Name: actasactivofijo iactasactivofijo3; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.actasactivofijo
    ADD CONSTRAINT iactasactivofijo3 FOREIGN KEY (actaaf_respon_id) REFERENCES msib.personal(per_id);


--
-- Name: actasactivofijo iactasactivofijo4; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.actasactivofijo
    ADD CONSTRAINT iactasactivofijo4 FOREIGN KEY (tipdoc_id) REFERENCES msib.tipodocumento(tipdoc_id);


--
-- Name: actasactivofijo iactasactivofijo5; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.actasactivofijo
    ADD CONSTRAINT iactasactivofijo5 FOREIGN KEY (actaaf_estadoacta_id) REFERENCES msib.tablabasedata(tabbasdat_id);


--
-- Name: actasactivofijoaf iactasactivofijoaf1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.actasactivofijoaf
    ADD CONSTRAINT iactasactivofijoaf1 FOREIGN KEY (actfij_id) REFERENCES msib.activofijo(actfij_id);


--
-- Name: actasactivofijoaf iactasactivofijoaf2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.actasactivofijoaf
    ADD CONSTRAINT iactasactivofijoaf2 FOREIGN KEY (actaaf_id) REFERENCES msib.actasactivofijo(actaaf_id);


--
-- Name: actasactivofijoaf iactasactivofijoaf3; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.actasactivofijoaf
    ADD CONSTRAINT iactasactivofijoaf3 FOREIGN KEY (actaaf_af_conservacion_id) REFERENCES msib.tablabasedata(tabbasdat_id);


--
-- Name: actasactivofijoaf iactasactivofijoaf4; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.actasactivofijoaf
    ADD CONSTRAINT iactasactivofijoaf4 FOREIGN KEY (actaaf_af_ofi_id) REFERENCES msib.oficinas(ofi_id);


--
-- Name: activofijo iactivofijo1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.activofijo
    ADD CONSTRAINT iactivofijo1 FOREIGN KEY (prv_id) REFERENCES msib.proveedor(prv_id);


--
-- Name: activofijo iactivofijo2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.activofijo
    ADD CONSTRAINT iactivofijo2 FOREIGN KEY (catitm_id) REFERENCES msib.categoriaitem(catitm_id);


--
-- Name: activofijo iactivofijo3; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.activofijo
    ADD CONSTRAINT iactivofijo3 FOREIGN KEY (ofi_id) REFERENCES msib.oficinas(ofi_id);


--
-- Name: activofijo iactivofijo4; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.activofijo
    ADD CONSTRAINT iactivofijo4 FOREIGN KEY (actfij_cus_id) REFERENCES msib.personal(per_id);


--
-- Name: activofijo iactivofijo5; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.activofijo
    ADD CONSTRAINT iactivofijo5 FOREIGN KEY (actfij_estado_custodia_id) REFERENCES msib.tablabasedata(tabbasdat_id);


--
-- Name: activofijohistorialestado iactivofijohistorialestado1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.activofijohistorialestado
    ADD CONSTRAINT iactivofijohistorialestado1 FOREIGN KEY (actfij_id) REFERENCES msib.activofijo(actfij_id);


--
-- Name: activofijohistorialestado iactivofijohistorialestado2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.activofijohistorialestado
    ADD CONSTRAINT iactivofijohistorialestado2 FOREIGN KEY (actfijhis_estado_activo_id) REFERENCES msib.tablabasedata(tabbasdat_id);


--
-- Name: almacen ialmacen1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.almacen
    ADD CONSTRAINT ialmacen1 FOREIGN KEY (ofi_id) REFERENCES msib.oficinas(ofi_id);


--
-- Name: almacencatalogoitem ialmacencatalogoitem1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.almacencatalogoitem
    ADD CONSTRAINT ialmacencatalogoitem1 FOREIGN KEY (almcataitmalm_id) REFERENCES msib.almacen(alm_id);


--
-- Name: almacencatalogoitem ialmacencatalogoitem2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.almacencatalogoitem
    ADD CONSTRAINT ialmacencatalogoitem2 FOREIGN KEY (cataitm_id) REFERENCES msib.catalogoitem(cataitm_id);


--
-- Name: asignacionpersonal iasignacionpersonal1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.asignacionpersonal
    ADD CONSTRAINT iasignacionpersonal1 FOREIGN KEY (asgperper_id) REFERENCES msib.personal(per_id);


--
-- Name: asignacionpersonal iasignacionpersonal2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.asignacionpersonal
    ADD CONSTRAINT iasignacionpersonal2 FOREIGN KEY (asgpercar_id) REFERENCES msib.cargo(car_id);


--
-- Name: autorizacionanulacion iautorizacionanulacion1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.autorizacionanulacion
    ADD CONSTRAINT iautorizacionanulacion1 FOREIGN KEY (autanuper_id) REFERENCES msib.personal(per_id);


--
-- Name: autorizacionanulacion iautorizacionanulacion2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.autorizacionanulacion
    ADD CONSTRAINT iautorizacionanulacion2 FOREIGN KEY (ofi_id) REFERENCES msib.oficinas(ofi_id);


--
-- Name: autorizacionanulacion iautorizacionanulacion3; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.autorizacionanulacion
    ADD CONSTRAINT iautorizacionanulacion3 FOREIGN KEY (solanuper_id) REFERENCES msib.personal(per_id);


--
-- Name: autorizacionanulacion iautorizacionanulacion4; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.autorizacionanulacion
    ADD CONSTRAINT iautorizacionanulacion4 FOREIGN KEY (autanu_estado_id) REFERENCES msib.tablabasedata(tabbasdat_id);


--
-- Name: catalogoitem icatalogoitem1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.catalogoitem
    ADD CONSTRAINT icatalogoitem1 FOREIGN KEY (catitm_id) REFERENCES msib.categoriaitem(catitm_id);


--
-- Name: catalogoitem icatalogoitem2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.catalogoitem
    ADD CONSTRAINT icatalogoitem2 FOREIGN KEY (cataitmunimed_id) REFERENCES msib.tablabasedata(tabbasdat_id);


--
-- Name: catalogoitemdigital icatalogoitemdigital1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.catalogoitemdigital
    ADD CONSTRAINT icatalogoitemdigital1 FOREIGN KEY (cataitm_id) REFERENCES msib.catalogoitem(cataitm_id);


--
-- Name: categoriaitem icategoriaitem1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.categoriaitem
    ADD CONSTRAINT icategoriaitem1 FOREIGN KEY (gruitm_id) REFERENCES msib.grupoitem(gruitm_id);


--
-- Name: centrocosto icentrocosto1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.centrocosto
    ADD CONSTRAINT icentrocosto1 FOREIGN KEY (ccosgru_id) REFERENCES msib.tablabasedata(tabbasdat_id);


--
-- Name: grupoitem igrupoitem1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.grupoitem
    ADD CONSTRAINT igrupoitem1 FOREIGN KEY (famitm_id) REFERENCES msib.familiaitem(famitm_id);


--
-- Name: ingresoalmacen iingresoalmacen1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.ingresoalmacen
    ADD CONSTRAINT iingresoalmacen1 FOREIGN KEY (ingalmalmori_id) REFERENCES msib.almacen(alm_id);


--
-- Name: ingresoalmacen iingresoalmacen2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.ingresoalmacen
    ADD CONSTRAINT iingresoalmacen2 FOREIGN KEY (ingalmalmdes_id) REFERENCES msib.almacen(alm_id);


--
-- Name: ingresoalmacen iingresoalmacen3; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.ingresoalmacen
    ADD CONSTRAINT iingresoalmacen3 FOREIGN KEY (ingalmalm_id) REFERENCES msib.almacen(alm_id);


--
-- Name: ingresoalmacen iingresoalmacen4; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.ingresoalmacen
    ADD CONSTRAINT iingresoalmacen4 FOREIGN KEY (ingalmprv_id) REFERENCES msib.proveedor(prv_id);


--
-- Name: ingresoalmacen iingresoalmacen5; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.ingresoalmacen
    ADD CONSTRAINT iingresoalmacen5 FOREIGN KEY (ingalmasgper_id) REFERENCES msib.asignacionpersonal(asgper_id);


--
-- Name: ingresoalmacen iingresoalmacen6; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.ingresoalmacen
    ADD CONSTRAINT iingresoalmacen6 FOREIGN KEY (ingalmtipdoc_id) REFERENCES msib.tipodocumento(tipdoc_id);


--
-- Name: ingresoalmacen iingresoalmacen7; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.ingresoalmacen
    ADD CONSTRAINT iingresoalmacen7 FOREIGN KEY (ingalm_estado_id) REFERENCES msib.tablabasedata(tabbasdat_id);


--
-- Name: ingresoalmacen iingresoalmacen8; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.ingresoalmacen
    ADD CONSTRAINT iingresoalmacen8 FOREIGN KEY (ingalmfuefin_id) REFERENCES msib.tablabasedata(tabbasdat_id);


--
-- Name: ingresoalmacenitem iingresoalmacenitem1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.ingresoalmacenitem
    ADD CONSTRAINT iingresoalmacenitem1 FOREIGN KEY (almcataitmalm_id, cataitm_id) REFERENCES msib.almacencatalogoitem(almcataitmalm_id, cataitm_id);


--
-- Name: ingresoalmacenitem iingresoalmacenitem2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.ingresoalmacenitem
    ADD CONSTRAINT iingresoalmacenitem2 FOREIGN KEY (ingalm_id) REFERENCES msib.ingresoalmacen(ingalm_id);


--
-- Name: ingresoalmacenitem iingresoalmacenitem3; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.ingresoalmacenitem
    ADD CONSTRAINT iingresoalmacenitem3 FOREIGN KEY (ingalmitmfuefin_id) REFERENCES msib.tablabasedata(tabbasdat_id);


--
-- Name: inventariofisico iinventariofisico1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.inventariofisico
    ADD CONSTRAINT iinventariofisico1 FOREIGN KEY (invfisalm_id) REFERENCES msib.almacen(alm_id);


--
-- Name: inventariofisicoitems iinventariofisicoitems1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.inventariofisicoitems
    ADD CONSTRAINT iinventariofisicoitems1 FOREIGN KEY (almitmdisfuefin_id) REFERENCES msib.tablabasedata(tabbasdat_id);


--
-- Name: inventariofisicoitems iinventariofisicoitems2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.inventariofisicoitems
    ADD CONSTRAINT iinventariofisicoitems2 FOREIGN KEY (almcataitmalm_id, cataitm_id) REFERENCES msib.almacencatalogoitem(almcataitmalm_id, cataitm_id);


--
-- Name: inventariofisicoitems iinventariofisicoitems3; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.inventariofisicoitems
    ADD CONSTRAINT iinventariofisicoitems3 FOREIGN KEY (invfis_id) REFERENCES msib.inventariofisico(invfis_id);


--
-- Name: kardexconsolidadomensual ikardexconsolidadomensual1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.kardexconsolidadomensual
    ADD CONSTRAINT ikardexconsolidadomensual1 FOREIGN KEY (almcataitmalm_id, cataitm_id) REFERENCES msib.almacencatalogoitem(almcataitmalm_id, cataitm_id);


--
-- Name: kardexconsolidadomensual ikardexconsolidadomensual2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.kardexconsolidadomensual
    ADD CONSTRAINT ikardexconsolidadomensual2 FOREIGN KEY (almitmdisfuefin_id) REFERENCES msib.tablabasedata(tabbasdat_id);


--
-- Name: kardexmovimientomensual ikardexmovimientomensual1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.kardexmovimientomensual
    ADD CONSTRAINT ikardexmovimientomensual1 FOREIGN KEY (almcataitmalm_id, cataitm_id) REFERENCES msib.almacencatalogoitem(almcataitmalm_id, cataitm_id);


--
-- Name: lineatelefonia ilineatelefonia1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.lineatelefonia
    ADD CONSTRAINT ilineatelefonia1 FOREIGN KEY (lintel_estadoid) REFERENCES msib.tablabasedata(tabbasdat_id);


--
-- Name: lineatelefonia ilineatelefonia2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.lineatelefonia
    ADD CONSTRAINT ilineatelefonia2 FOREIGN KEY (lintel_ofi_id) REFERENCES msib.oficinas(ofi_id);


--
-- Name: lineatelefonia ilineatelefonia3; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.lineatelefonia
    ADD CONSTRAINT ilineatelefonia3 FOREIGN KEY (actfij_id) REFERENCES msib.activofijo(actfij_id);


--
-- Name: logcierremesinventarioalmacen ilogcierremesinventarioalmacen1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.logcierremesinventarioalmacen
    ADD CONSTRAINT ilogcierremesinventarioalmacen1 FOREIGN KEY (alm_id) REFERENCES msib.almacen(alm_id);


--
-- Name: logcierremesinventarioalmacen ilogcierremesinventarioalmacen2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.logcierremesinventarioalmacen
    ADD CONSTRAINT ilogcierremesinventarioalmacen2 FOREIGN KEY (logcieinv_mes, logcieinv_anio) REFERENCES msib.logcierremesinventario(logcieinv_mes, logcieinv_anio);


--
-- Name: menuitem imenuitem1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.menuitem
    ADD CONSTRAINT imenuitem1 FOREIGN KEY (menuitemfatherid) REFERENCES msib.menuitem(menuitemid);


--
-- Name: menuitem imenuitem2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.menuitem
    ADD CONSTRAINT imenuitem2 FOREIGN KEY (secfunctionalityid) REFERENCES msib.secfunctionality(secfunctionalityid);


--
-- Name: numerofolioalmacen inumerofolioalmacen1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.numerofolioalmacen
    ADD CONSTRAINT inumerofolioalmacen1 FOREIGN KEY (alm_id) REFERENCES msib.almacen(alm_id);


--
-- Name: oficinas ioficinas1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.oficinas
    ADD CONSTRAINT ioficinas1 FOREIGN KEY (ofican_id) REFERENCES msib.tablabasedata(tabbasdat_id);


--
-- Name: oficinas ioficinas2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.oficinas
    ADD CONSTRAINT ioficinas2 FOREIGN KEY (ccos_id) REFERENCES msib.centrocosto(ccos_id);


--
-- Name: parametroconfiguracionitem iparametroconfiguracionitem1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.parametroconfiguracionitem
    ADD CONSTRAINT iparametroconfiguracionitem1 FOREIGN KEY (parcfg_id) REFERENCES msib.parametroconfiguracion(parcfg_id);


--
-- Name: planificar_compra_ratio_item iplanificar_compra_ratiocataitm_1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.planificar_compra_ratio_item
    ADD CONSTRAINT iplanificar_compra_ratiocataitm_1 FOREIGN KEY (cataitm_id) REFERENCES msib.catalogoitem(cataitm_id);


--
-- Name: planificar_compra_ratio_item iplanificar_compra_ratiocataitm_2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.planificar_compra_ratio_item
    ADD CONSTRAINT iplanificar_compra_ratiocataitm_2 FOREIGN KEY (placomrat_id) REFERENCES msib.planificar_compra_ratio(placomrat_id);


--
-- Name: planificar_compra_ratio_item_almacen iplanificar_compra_ratioitemalmacen1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.planificar_compra_ratio_item_almacen
    ADD CONSTRAINT iplanificar_compra_ratioitemalmacen1 FOREIGN KEY (placomalm_alm_id) REFERENCES msib.almacen(alm_id);


--
-- Name: planificar_compra_ratio_item_almacen iplanificar_compra_ratioitemalmacen2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.planificar_compra_ratio_item_almacen
    ADD CONSTRAINT iplanificar_compra_ratioitemalmacen2 FOREIGN KEY (placomrat_id, cataitm_id) REFERENCES msib.planificar_compra_ratio_item(placomrat_id, cataitm_id);


--
-- Name: planillamessalida iplanillamessalida1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.planillamessalida
    ADD CONSTRAINT iplanillamessalida1 FOREIGN KEY (plamessal_alm_id) REFERENCES msib.almacen(alm_id);


--
-- Name: planillamessalidaitem iplanillamessalidaitem1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.planillamessalidaitem
    ADD CONSTRAINT iplanillamessalidaitem1 FOREIGN KEY (almcataitmalm_id, cataitm_id) REFERENCES msib.almacencatalogoitem(almcataitmalm_id, cataitm_id);


--
-- Name: planillamessalidaitem iplanillamessalidaitem2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.planillamessalidaitem
    ADD CONSTRAINT iplanillamessalidaitem2 FOREIGN KEY (plamessal_id) REFERENCES msib.planillamessalida(plamessal_id);


--
-- Name: planillamessalidanota iplanillamessalidanota1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.planillamessalidanota
    ADD CONSTRAINT iplanillamessalidanota1 FOREIGN KEY (plamessal_id) REFERENCES msib.planillamessalida(plamessal_id);


--
-- Name: plantilla_producto_simulador_item iplantilla_producto_simuladoritem1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.plantilla_producto_simulador_item
    ADD CONSTRAINT iplantilla_producto_simuladoritem1 FOREIGN KEY (cataitm_id) REFERENCES msib.catalogoitem(cataitm_id);


--
-- Name: plantilla_producto_simulador_item iplantilla_producto_simuladoritem2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.plantilla_producto_simulador_item
    ADD CONSTRAINT iplantilla_producto_simuladoritem2 FOREIGN KEY (plaprosim_id) REFERENCES msib.plantilla_producto_simulador(plaprosim_id);


--
-- Name: proveedor iproveedor1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.proveedor
    ADD CONSTRAINT iproveedor1 FOREIGN KEY (prvtipprv_id) REFERENCES msib.tablabasedata(tabbasdat_id);


--
-- Name: resumencostoinventario iresumencostoinventario1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.resumencostoinventario
    ADD CONSTRAINT iresumencostoinventario1 FOREIGN KEY (almitmdisfuefin_id) REFERENCES msib.tablabasedata(tabbasdat_id);


--
-- Name: resumencostoinventario iresumencostoinventario2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.resumencostoinventario
    ADD CONSTRAINT iresumencostoinventario2 FOREIGN KEY (almcataitmalm_id, cataitm_id) REFERENCES msib.almacencatalogoitem(almcataitmalm_id, cataitm_id);


--
-- Name: salidaalmacen isalidaalmacen1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.salidaalmacen
    ADD CONSTRAINT isalidaalmacen1 FOREIGN KEY (salalmalmori_id) REFERENCES msib.almacen(alm_id);


--
-- Name: salidaalmacen isalidaalmacen2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.salidaalmacen
    ADD CONSTRAINT isalidaalmacen2 FOREIGN KEY (salalmalmdes_id) REFERENCES msib.almacen(alm_id);


--
-- Name: salidaalmacen isalidaalmacen3; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.salidaalmacen
    ADD CONSTRAINT isalidaalmacen3 FOREIGN KEY (salalmalm_id) REFERENCES msib.almacen(alm_id);


--
-- Name: salidaalmacen isalidaalmacen4; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.salidaalmacen
    ADD CONSTRAINT isalidaalmacen4 FOREIGN KEY (salalmprv_id) REFERENCES msib.proveedor(prv_id);


--
-- Name: salidaalmacen isalidaalmacen5; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.salidaalmacen
    ADD CONSTRAINT isalidaalmacen5 FOREIGN KEY (salalmasgper_id) REFERENCES msib.asignacionpersonal(asgper_id);


--
-- Name: salidaalmacen isalidaalmacen6; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.salidaalmacen
    ADD CONSTRAINT isalidaalmacen6 FOREIGN KEY (salalmtipdoc_id) REFERENCES msib.tipodocumento(tipdoc_id);


--
-- Name: salidaalmacen isalidaalmacen7; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.salidaalmacen
    ADD CONSTRAINT isalidaalmacen7 FOREIGN KEY (salalm_estado_id) REFERENCES msib.tablabasedata(tabbasdat_id);


--
-- Name: salidaalmacen isalidaalmacen8; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.salidaalmacen
    ADD CONSTRAINT isalidaalmacen8 FOREIGN KEY (salalm_estadotrans_id) REFERENCES msib.tablabasedata(tabbasdat_id);


--
-- Name: salidaalmacen isalidaalmacen9; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.salidaalmacen
    ADD CONSTRAINT isalidaalmacen9 FOREIGN KEY (salalmfuefin_id) REFERENCES msib.tablabasedata(tabbasdat_id);


--
-- Name: salidaalmacenitem isalidaalmacenitem1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.salidaalmacenitem
    ADD CONSTRAINT isalidaalmacenitem1 FOREIGN KEY (almcataitmalm_id, cataitm_id) REFERENCES msib.almacencatalogoitem(almcataitmalm_id, cataitm_id);


--
-- Name: salidaalmacenitem isalidaalmacenitem2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.salidaalmacenitem
    ADD CONSTRAINT isalidaalmacenitem2 FOREIGN KEY (salalm_id) REFERENCES msib.salidaalmacen(salalm_id);


--
-- Name: salidaalmacenitem isalidaalmacenitem3; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.salidaalmacenitem
    ADD CONSTRAINT isalidaalmacenitem3 FOREIGN KEY (salalmitmfuefin_id) REFERENCES msib.tablabasedata(tabbasdat_id);


--
-- Name: secfunctionality isecfunctionality1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.secfunctionality
    ADD CONSTRAINT isecfunctionality1 FOREIGN KEY (secparentfunctionalityid) REFERENCES msib.secfunctionality(secfunctionalityid);


--
-- Name: secfunctionalityrole isecfunctionalityrol1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.secfunctionalityrole
    ADD CONSTRAINT isecfunctionalityrol1 FOREIGN KEY (secfunctionalityid) REFERENCES msib.secfunctionality(secfunctionalityid);


--
-- Name: secfunctionalityrole isecfunctionalityrol2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.secfunctionalityrole
    ADD CONSTRAINT isecfunctionalityrol2 FOREIGN KEY (secroleid) REFERENCES msib.secrole(secroleid);


--
-- Name: secobjectfunctionalities isecobjectfunctionalities1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.secobjectfunctionalities
    ADD CONSTRAINT isecobjectfunctionalities1 FOREIGN KEY (secfunctionalityid) REFERENCES msib.secfunctionality(secfunctionalityid);


--
-- Name: secobjectfunctionalities isecobjectfunctionalities2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.secobjectfunctionalities
    ADD CONSTRAINT isecobjectfunctionalities2 FOREIGN KEY (secobjectname) REFERENCES msib.secobject(secobjectname);


--
-- Name: secuseralmacen isecuseralmacen1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.secuseralmacen
    ADD CONSTRAINT isecuseralmacen1 FOREIGN KEY (alm_id) REFERENCES msib.almacen(alm_id);


--
-- Name: secuseralmacen isecuseralmacen2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.secuseralmacen
    ADD CONSTRAINT isecuseralmacen2 FOREIGN KEY (secuserid) REFERENCES msib.secuser(secuserid);


--
-- Name: secuseroficina isecuseroficina1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.secuseroficina
    ADD CONSTRAINT isecuseroficina1 FOREIGN KEY (ofi_id) REFERENCES msib.oficinas(ofi_id);


--
-- Name: secuseroficina isecuseroficina2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.secuseroficina
    ADD CONSTRAINT isecuseroficina2 FOREIGN KEY (secuserid) REFERENCES msib.secuser(secuserid);


--
-- Name: secuserrole isecuserrole1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.secuserrole
    ADD CONSTRAINT isecuserrole1 FOREIGN KEY (secroleid) REFERENCES msib.secrole(secroleid);


--
-- Name: secuserrole isecuserrole2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.secuserrole
    ADD CONSTRAINT isecuserrole2 FOREIGN KEY (secuserid) REFERENCES msib.secuser(secuserid);


--
-- Name: tablabasedata itablabasedata1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.tablabasedata
    ADD CONSTRAINT itablabasedata1 FOREIGN KEY (tabbasgru_id) REFERENCES msib.tablabasegrupo(tabbasgru_id);


--
-- Name: tipodocumento itipodocumento1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.tipodocumento
    ADD CONSTRAINT itipodocumento1 FOREIGN KEY (tipdoccatdoc_id) REFERENCES msib.tablabasedata(tabbasdat_id);


--
-- Name: wwp_mail iwwp_mail1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.wwp_mail
    ADD CONSTRAINT iwwp_mail1 FOREIGN KEY (wwpnotificationid) REFERENCES msib.wwp_notification(wwpnotificationid);


--
-- Name: wwp_mailattachments iwwp_mailattachments1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.wwp_mailattachments
    ADD CONSTRAINT iwwp_mailattachments1 FOREIGN KEY (wwpmailid) REFERENCES msib.wwp_mail(wwpmailid);


--
-- Name: wwp_notification iwwp_notification1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.wwp_notification
    ADD CONSTRAINT iwwp_notification1 FOREIGN KEY (wwpuserextendedid) REFERENCES msib.wwp_userextended(wwpuserextendedid);


--
-- Name: wwp_notification iwwp_notification2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.wwp_notification
    ADD CONSTRAINT iwwp_notification2 FOREIGN KEY (wwpnotificationdefinitionid) REFERENCES msib.wwp_notificationdefinition(wwpnotificationdefinitionid);


--
-- Name: wwp_notificationdefinition iwwp_notificationdefinition1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.wwp_notificationdefinition
    ADD CONSTRAINT iwwp_notificationdefinition1 FOREIGN KEY (wwpentityid) REFERENCES msib.wwp_entity(wwpentityid);


--
-- Name: wwp_sms iwwp_sms1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.wwp_sms
    ADD CONSTRAINT iwwp_sms1 FOREIGN KEY (wwpnotificationid) REFERENCES msib.wwp_notification(wwpnotificationid);


--
-- Name: wwp_subscription iwwp_subscription1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.wwp_subscription
    ADD CONSTRAINT iwwp_subscription1 FOREIGN KEY (wwpuserextendedid) REFERENCES msib.wwp_userextended(wwpuserextendedid);


--
-- Name: wwp_subscription iwwp_subscription2; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.wwp_subscription
    ADD CONSTRAINT iwwp_subscription2 FOREIGN KEY (wwpnotificationdefinitionid) REFERENCES msib.wwp_notificationdefinition(wwpnotificationdefinitionid);


--
-- Name: wwp_webclient iwwp_webclient1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.wwp_webclient
    ADD CONSTRAINT iwwp_webclient1 FOREIGN KEY (wwpuserextendedid) REFERENCES msib.wwp_userextended(wwpuserextendedid);


--
-- Name: wwp_webnotification iwwp_webnotification1; Type: FK CONSTRAINT; Schema: msib; Owner: -
--

ALTER TABLE ONLY msib.wwp_webnotification
    ADD CONSTRAINT iwwp_webnotification1 FOREIGN KEY (wwpnotificationid) REFERENCES msib.wwp_notification(wwpnotificationid);


--
-- PostgreSQL database dump complete
--

