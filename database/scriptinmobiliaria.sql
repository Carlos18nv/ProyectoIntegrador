--
-- PostgreSQL database dump
--

\restrict wsBSAtazRTYdmfAAvNCz3Sw8doZIdDsd5c5WDyOKJRqY7iXu2Hb8FSblfpDfAnN

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

-- Started on 2026-08-27 00:41:21

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 227 (class 1255 OID 90221)
-- Name: actualizar_estado_propiedad(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.actualizar_estado_propiedad() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.estado = 'confirmada' THEN
        UPDATE propiedades SET estado = 'vendida' WHERE id = NEW.id_propiedad;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.actualizar_estado_propiedad() OWNER TO postgres;

--
-- TOC entry 241 (class 1255 OID 90223)
-- Name: registrar_compra(integer, character varying, numeric, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.registrar_compra(IN p_id_propiedad integer, IN p_nombre_comprador character varying, IN p_monto numeric, IN p_id_visita integer DEFAULT NULL::integer, IN p_id_registrado_por integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_estado_actual VARCHAR(20);
BEGIN
    SELECT estado INTO v_estado_actual FROM propiedades WHERE id = p_id_propiedad;

    IF v_estado_actual IS NULL THEN
        RAISE EXCEPTION 'La propiedad con ID % no existe', p_id_propiedad;
    END IF;

    IF v_estado_actual = 'vendida' THEN
        RAISE EXCEPTION 'La propiedad con ID % ya fue vendida, no se puede registrar otra compra', p_id_propiedad;
    END IF;

    INSERT INTO compras (id_propiedad, id_visita, nombre_comprador, monto, id_registrado_por, estado)
    VALUES (p_id_propiedad, p_id_visita, p_nombre_comprador, p_monto, p_id_registrado_por, 'confirmada');
END;
$$;


ALTER PROCEDURE public.registrar_compra(IN p_id_propiedad integer, IN p_nombre_comprador character varying, IN p_monto numeric, IN p_id_visita integer, IN p_id_registrado_por integer) OWNER TO postgres;

--
-- TOC entry 239 (class 1255 OID 90224)
-- Name: reporte_ventas(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.reporte_ventas(fecha_inicio date, fecha_fin date) RETURNS TABLE(propiedad character varying, comprador character varying, monto numeric, registrado_por character varying, fecha timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT p.titulo, c.nombre_comprador, c.monto, u.nombre, c.fecha_compra
    FROM compras c
    JOIN propiedades p ON c.id_propiedad = p.id
    LEFT JOIN usuarios u ON c.id_registrado_por = u.id
    WHERE c.estado = 'confirmada'
      AND c.fecha_compra BETWEEN fecha_inicio AND fecha_fin;
END;
$$;


ALTER FUNCTION public.reporte_ventas(fecha_inicio date, fecha_fin date) OWNER TO postgres;

--
-- TOC entry 240 (class 1255 OID 90225)
-- Name: reporte_visitas_pendientes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.reporte_visitas_pendientes() RETURNS TABLE(codigo character varying, cliente character varying, propiedad character varying, fecha date, hora character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT v.codigo_solicitud, v.nombre_cliente, p.titulo, v.fecha_visita, v.hora_visita
    FROM visitas v
    JOIN propiedades p ON v.id_propiedad = p.id
    WHERE v.estado = 'pendiente'
    ORDER BY v.fecha_visita, v.hora_visita;
END;
$$;


ALTER FUNCTION public.reporte_visitas_pendientes() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 226 (class 1259 OID 90840)
-- Name: compras; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compras (
    id integer NOT NULL,
    id_propiedad integer NOT NULL,
    id_visita integer,
    nombre_comprador character varying(100) NOT NULL,
    monto numeric(12,2) NOT NULL,
    id_registrado_por integer,
    estado character varying(20) NOT NULL,
    fecha_compra timestamp without time zone
);


ALTER TABLE public.compras OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 90839)
-- Name: compras_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.compras_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.compras_id_seq OWNER TO postgres;

--
-- TOC entry 4957 (class 0 OID 0)
-- Dependencies: 225
-- Name: compras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.compras_id_seq OWNED BY public.compras.id;


--
-- TOC entry 222 (class 1259 OID 90792)
-- Name: propiedades; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.propiedades (
    id integer NOT NULL,
    codigo character varying(20) NOT NULL,
    titulo character varying(150) NOT NULL,
    precio numeric(12,2) NOT NULL,
    area_m2 numeric(8,2) NOT NULL,
    direccion character varying(200) NOT NULL,
    sector character varying(80),
    descripcion text,
    dormitorios integer,
    banos integer,
    permite_mascotas boolean,
    num_pisos integer,
    tiene_ascensor boolean,
    uso_suelo character varying(50),
    estado character varying(20) NOT NULL,
    id_agente integer,
    activo boolean,
    fecha_publicacion timestamp without time zone,
    tipo character varying(20),
    imagen_url character varying(300)
);


ALTER TABLE public.propiedades OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 90791)
-- Name: propiedades_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.propiedades_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.propiedades_id_seq OWNER TO postgres;

--
-- TOC entry 4958 (class 0 OID 0)
-- Dependencies: 221
-- Name: propiedades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.propiedades_id_seq OWNED BY public.propiedades.id;


--
-- TOC entry 220 (class 1259 OID 90778)
-- Name: usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuarios (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    email character varying(120) NOT NULL,
    password_hash character varying(255) NOT NULL,
    rol character varying(20) NOT NULL,
    fecha_registro timestamp without time zone
);


ALTER TABLE public.usuarios OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 90777)
-- Name: usuarios_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuarios_id_seq OWNER TO postgres;

--
-- TOC entry 4959 (class 0 OID 0)
-- Dependencies: 219
-- Name: usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuarios_id_seq OWNED BY public.usuarios.id;


--
-- TOC entry 224 (class 1259 OID 90815)
-- Name: visitas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.visitas (
    id integer NOT NULL,
    codigo_solicitud character varying(20) NOT NULL,
    id_propiedad integer NOT NULL,
    nombre_cliente character varying(100) NOT NULL,
    telefono character varying(20) NOT NULL,
    correo character varying(120) NOT NULL,
    fecha_visita date NOT NULL,
    hora_visita character varying(20) NOT NULL,
    mensaje text,
    estado character varying(20) NOT NULL,
    fecha_creacion timestamp without time zone
);


ALTER TABLE public.visitas OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 90814)
-- Name: visitas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.visitas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.visitas_id_seq OWNER TO postgres;

--
-- TOC entry 4960 (class 0 OID 0)
-- Dependencies: 223
-- Name: visitas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.visitas_id_seq OWNED BY public.visitas.id;


--
-- TOC entry 4777 (class 2604 OID 90843)
-- Name: compras id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras ALTER COLUMN id SET DEFAULT nextval('public.compras_id_seq'::regclass);


--
-- TOC entry 4775 (class 2604 OID 90795)
-- Name: propiedades id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.propiedades ALTER COLUMN id SET DEFAULT nextval('public.propiedades_id_seq'::regclass);


--
-- TOC entry 4774 (class 2604 OID 90781)
-- Name: usuarios id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios ALTER COLUMN id SET DEFAULT nextval('public.usuarios_id_seq'::regclass);


--
-- TOC entry 4776 (class 2604 OID 90818)
-- Name: visitas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.visitas ALTER COLUMN id SET DEFAULT nextval('public.visitas_id_seq'::regclass);


--
-- TOC entry 4951 (class 0 OID 90840)
-- Dependencies: 226
-- Data for Name: compras; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compras (id, id_propiedad, id_visita, nombre_comprador, monto, id_registrado_por, estado, fecha_compra) FROM stdin;
1	1	\N	carlos	200.00	1	confirmada	\N
\.


--
-- TOC entry 4947 (class 0 OID 90792)
-- Dependencies: 222
-- Data for Name: propiedades; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.propiedades (id, codigo, titulo, precio, area_m2, direccion, sector, descripcion, dormitorios, banos, permite_mascotas, num_pisos, tiene_ascensor, uso_suelo, estado, id_agente, activo, fecha_publicacion, tipo, imagen_url) FROM stdin;
1	CAS001	Casa moderna en Cumbaya	350000.00	210.00	Cumbaya, Quito	Cumbaya	\N	3	2	t	2	\N	\N	disponible	2	t	2026-08-26 08:19:43.530952	casa	/static/imagenes/property-1.png
2	DEP001	Departamento con terraza	145000.00	120.00	Tumbaco, Quito	Tumbaco	\N	3	2	f	\N	t	\N	disponible	2	t	2026-08-26 08:19:43.530956	departamento	/static/imagenes/property-2.png
3	TER001	Terreno residencial	60000.00	500.00	Quitumbe, Quito	Quitumbe	\N	\N	\N	f	\N	\N	residencial	disponible	2	t	2026-08-26 08:19:43.535495	terreno	/static/imagenes/property-3.png
\.


--
-- TOC entry 4945 (class 0 OID 90778)
-- Dependencies: 220
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuarios (id, nombre, email, password_hash, rol, fecha_registro) FROM stdin;
1	Admin Principal	admin@hogar.com	scrypt:32768:8:1$EgicOkmBBfdPOytc$46d3b82c22658a71cecbdda26c03ff13a6e2af305f72894d1e5a02b9c4134ea860a61238263de1cc5c3649460a4cbfe2df758f997bc2304ac908542610ab1033	admin	2026-08-26 08:19:43.519403
2	Agente Demo	agente@hogar.com	scrypt:32768:8:1$mHwvbV3pnGTLtAhE$acd5b26a8ac6406a2386251f8c8b8006d53093efa38cadd5b94f939e451cf975b65f3a2603e8848979e7e27ac48fe33da0abf2d100a9c383e4c51692f5506657	agente	2026-08-26 08:19:43.519408
\.


--
-- TOC entry 4949 (class 0 OID 90815)
-- Dependencies: 224
-- Data for Name: visitas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.visitas (id, codigo_solicitud, id_propiedad, nombre_cliente, telefono, correo, fecha_visita, hora_visita, mensaje, estado, fecha_creacion) FROM stdin;
\.


--
-- TOC entry 4961 (class 0 OID 0)
-- Dependencies: 225
-- Name: compras_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.compras_id_seq', 1, true);


--
-- TOC entry 4962 (class 0 OID 0)
-- Dependencies: 221
-- Name: propiedades_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.propiedades_id_seq', 3, true);


--
-- TOC entry 4963 (class 0 OID 0)
-- Dependencies: 219
-- Name: usuarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuarios_id_seq', 2, true);


--
-- TOC entry 4964 (class 0 OID 0)
-- Dependencies: 223
-- Name: visitas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.visitas_id_seq', 1, false);


--
-- TOC entry 4791 (class 2606 OID 90850)
-- Name: compras compras_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_pkey PRIMARY KEY (id);


--
-- TOC entry 4783 (class 2606 OID 90808)
-- Name: propiedades propiedades_codigo_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.propiedades
    ADD CONSTRAINT propiedades_codigo_key UNIQUE (codigo);


--
-- TOC entry 4785 (class 2606 OID 90806)
-- Name: propiedades propiedades_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.propiedades
    ADD CONSTRAINT propiedades_pkey PRIMARY KEY (id);


--
-- TOC entry 4779 (class 2606 OID 90790)
-- Name: usuarios usuarios_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_email_key UNIQUE (email);


--
-- TOC entry 4781 (class 2606 OID 90788)
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);


--
-- TOC entry 4787 (class 2606 OID 90833)
-- Name: visitas visitas_codigo_solicitud_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.visitas
    ADD CONSTRAINT visitas_codigo_solicitud_key UNIQUE (codigo_solicitud);


--
-- TOC entry 4789 (class 2606 OID 90831)
-- Name: visitas visitas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.visitas
    ADD CONSTRAINT visitas_pkey PRIMARY KEY (id);


--
-- TOC entry 4794 (class 2606 OID 90851)
-- Name: compras compras_id_propiedad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_id_propiedad_fkey FOREIGN KEY (id_propiedad) REFERENCES public.propiedades(id);


--
-- TOC entry 4795 (class 2606 OID 90861)
-- Name: compras compras_id_registrado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_id_registrado_por_fkey FOREIGN KEY (id_registrado_por) REFERENCES public.usuarios(id);


--
-- TOC entry 4796 (class 2606 OID 90856)
-- Name: compras compras_id_visita_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_id_visita_fkey FOREIGN KEY (id_visita) REFERENCES public.visitas(id);


--
-- TOC entry 4792 (class 2606 OID 90809)
-- Name: propiedades propiedades_id_agente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.propiedades
    ADD CONSTRAINT propiedades_id_agente_fkey FOREIGN KEY (id_agente) REFERENCES public.usuarios(id);


--
-- TOC entry 4793 (class 2606 OID 90834)
-- Name: visitas visitas_id_propiedad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.visitas
    ADD CONSTRAINT visitas_id_propiedad_fkey FOREIGN KEY (id_propiedad) REFERENCES public.propiedades(id);


-- Completed on 2026-08-27 00:41:23

--
-- PostgreSQL database dump complete
--

\unrestrict wsBSAtazRTYdmfAAvNCz3Sw8doZIdDsd5c5WDyOKJRqY7iXu2Hb8FSblfpDfAnN

