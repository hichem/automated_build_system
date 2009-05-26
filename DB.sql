-- Création de la base

create database vlab;
grant all on vlab.* to apache@'localhost' identified by 'myvlab';
use vlab;

create table users(id int (16) auto_increment, nom varchar(20) not null, prenom varchar(20) not null, email varchar(40) not null, login varchar(20) not null, passwd varchar(20) not null, rights varchar(10) not null, primary key(id));

create table project(id int (16) auto_increment, usr_id int (16) not null, title varchar(30) not null, description varchar(200) not null, architecture varchar(20) not null, variant varchar(20), creation_date date, primary key (id), foreign key (usr_id) references users(id));

create table configuration(c_id int (16) auto_increment, proj_id int (16) not null, name varchar(30) not null, toolchain varchar(50) not null, kernel_config varchar(50) not null, rt_extension varchar(20) not null, status varchar(30) not null, pid int(16), kernel_version varchar(20) not null, primary key(c_id),foreign key(proj_id) references project(id));

create table toolchain (id int(16) auto_increment, usr_id int(16) not null, name varchar(50) not null, status varchar(30) not null, creation_date date, build_date date, pid int(16), primary key(id), foreign key(usr_id) references users(id));

create table arch_variant (id int(5) auto_increment, arch varchar(20) not null, variant varchar(30) not null, primary key(id));


-- Insertion de données
	
	-- Administrateur du Vlab
	insert into users values (0, 'admin', 'admin', 'admin@domain', 'admin', 'admin', 'admin');
	
	-- Variantes des architectures cibles supportées par crosstool-ng
	insert into arch_variant (0, 'alpha', 'ev4');
	insert into arch_variant (0, 'alpha', 'ev45');
	insert into arch_variant (0, 'alpha', 'ev5');
	insert into arch_variant (0, 'alpha', 'ev56');
	insert into arch_variant (0, 'alpha', 'ev6');
	insert into arch_variant (0, 'alpha', 'ev67');
	
	insert into arch_variant (0, 'sh', 'sh3');
	insert into arch_variant (0, 'sh', 'sh4');
	insert into arch_variant (0, 'sh', 'sh4a');
	
	insert into arch_variant (0, 'x86', 'i386');
	insert into arch_variant (0, 'x86', 'i486');
	insert into arch_variant (0, 'x86', 'i586');
	insert into arch_variant (0, 'x86', 'i686');
