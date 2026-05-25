-- ============================================================================
-- DESAFIO DE PROJETO: ESQUEMA RELACIONAL DE OFICINA (DIO)
-- Script: Definição de Estrutura (DDL)
-- Autor: Victor Hugo
-- ============================================================================

-- Criação do Banco de Dados para o cenário de Oficina
create database if not exists Oficina;
use Oficina;

-- Tabela Cliente 
create table Cliente (
    idCliente int auto_increment primary key,
    Tipo_Cliente enum('PF', 'PJ') not null,
    Telefone varchar(15),
    Endereco varchar(255) not null
);

-- Tabela Cliente_PF (Pessoa Física)
create table Cliente_PF (
    CPF char(11) primary key,
    Nome varchar(45) not null,
    Cliente_idCliente int not null,
    CONSTRAINT fk_clientepf_cliente FOREIGN KEY (Cliente_idCliente) references Cliente(idCliente) on delete CASCADE
);

-- Tabela Cliente_PJ (Pessoa Jurídica)
create table Cliente_PJ (
    CNPJ char(14) primary key,
    Razao_Social varchar(100) not null,
    Inscricao_Estadual varchar(20) not null,
    Cliente_idCliente int not null,
    CONSTRAINT fk_clientepj_cliente FOREIGN KEY (Cliente_idCliente) references Cliente(idCliente) on delete CASCADE
);

-- Tabela Veiculo
create table Veiculo (
    idVeiculo int auto_increment primary key,
    Placa char(7) not null unique,
    Marca varchar(30) not null,
    Modelo varchar(50) not null,
    Ano smallint not null,
    Cliente_idCliente int not null,
    CONSTRAINT fk_veiculo_cliente FOREIGN KEY (Cliente_idCliente) references Cliente(idCliente)
);

-- Tabela Equipe de Mecânicos
create table Equipe_Mecanicos (
    idEquipe int auto_increment primary key,
    Nome_Equipe varchar(50) not null
);

-- Tabela Mecanico
create table Mecanico (
    idMecanico int auto_increment primary key,
    Codigo varchar(10) not null unique,
    Nome varchar(100) not null,
    Endereco varchar(255),
    Especialidade varchar(50) not null,
    Equipe_Mecanicos_idEquipe int not null,
    CONSTRAINT fk_mecanico_equipe FOREIGN KEY (Equipe_Mecanicos_idEquipe) references Equipe_Mecanicos(idEquipe)
);

-- Tabela Serviço
create table Servico (
    idServico int auto_increment primary key,
    Descricao varchar(150) not null,
    Valor_Mao_Obra decimal(10,2) not null
);

-- Tabela Peça
create table Peca (
    idPeca int auto_increment primary key,
    Codigo_Peca varchar(20) not null unique,
    Descricao varchar(150) not null,
    Valor_Unitario decimal(10,2) not null
);

-- Tabela Ordem de Serviço
create table OS (
    idOS int auto_increment primary key,
    Numero_OS int not null unique,
    Data_Emissao datetime not null,
    Data_Conclusao datetime,
    Valor_Total decimal(10,2) default 0.00,
    Status VARCHAR(30) not null,
    Equipe_Mecanicos_idEquipe int not null,
    Veiculo_idVeiculo int not null,
    Veiculo_Cliente_idCliente int not null,
    CONSTRAINT fk_os_equipe FOREIGN KEY (Equipe_Mecanicos_idEquipe) references Equipe_Mecanicos(idEquipe),
    CONSTRAINT fk_os_veiculo FOREIGN KEY (Veiculo_idVeiculo) references Veiculo(idVeiculo),
    CONSTRAINT fk_os_cliente FOREIGN KEY (Veiculo_Cliente_idCliente) references Cliente(idCliente)
);

-- Tabela Associativa: Itens_Serviço_OS
create table Itens_Servico_OS (
    Servico_idServico int not null,
    OS_idOS int not null,
    Quantidade tinyint not null default 1,
    Valor_Cobrado decimal(10,2) not null,
    primary key (Servico_idServico, OS_idOS),
    CONSTRAINT fk_itens_servico_servico FOREIGN KEY (Servico_idServico) references Servico(idServico),
    CONSTRAINT fk_itens_servico_os FOREIGN KEY (OS_idOS) references OS(idOS) on delete CASCADE
);

-- Tabela Associativa: Itens_Peça_OS
create table Itens_Peca_OS (
    OS_idOS int not null,
    Quantidade int not null default 1,
    Valor_Unitario_Cobrado decimal(10,2) not null,
    Peca_idPeca int not null,
    primary key (OS_idOS, Peca_idPeca),
    CONSTRAINT fk_itens_peca_os FOREIGN KEY (OS_idOS) references OS(idOS) on delete CASCADE,
    CONSTRAINT fk_itens_peca_peca FOREIGN KEY (Peca_idPeca) references Peca(idPeca)
);
