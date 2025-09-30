-- ==========================================================
-- Script de Criação do Banco de Dados: motosdb
-- ==========================================================

-- Remove o banco de dados se já existir
DROP DATABASE IF EXISTS motosdb;

-- Cria o banco de dados novamente
CREATE DATABASE motosdb
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE motosdb;

-- ==========================================================
-- Tabela: Patios
-- ==========================================================
DROP TABLE IF EXISTS Gerentes;
DROP TABLE IF EXISTS Funcionarios;
DROP TABLE IF EXISTS Patios;

CREATE TABLE Patios (
    Id INT NOT NULL AUTO_INCREMENT,
    Nome VARCHAR(100) NOT NULL,
    Endereco VARCHAR(200) NOT NULL,
    GerenteId INT NULL,
    CONSTRAINT PK_Patios PRIMARY KEY (Id)
) CHARACTER SET = utf8mb4;

-- ==========================================================
-- Tabela: Funcionarios
-- ==========================================================
CREATE TABLE Funcionarios (
    Id INT NOT NULL AUTO_INCREMENT,
    Nome VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Senha VARCHAR(256) NOT NULL,
    PatioId INT NOT NULL,
    CONSTRAINT PK_Funcionarios PRIMARY KEY (Id),
    CONSTRAINT FK_Funcionarios_Patios FOREIGN KEY (PatioId)
        REFERENCES Patios (Id)
        ON DELETE CASCADE
) CHARACTER SET = utf8mb4;

-- ==========================================================
-- Tabela: Gerentes
-- ==========================================================
CREATE TABLE Gerentes (
    Id INT NOT NULL AUTO_INCREMENT,
    FuncionarioId INT NOT NULL,
    PatioId INT NOT NULL,
    CONSTRAINT PK_Gerentes PRIMARY KEY (Id),
    CONSTRAINT FK_Gerentes_Funcionarios FOREIGN KEY (FuncionarioId)
        REFERENCES Funcionarios (Id)
        ON DELETE CASCADE,
    CONSTRAINT FK_Gerentes_Patios FOREIGN KEY (PatioId)
        REFERENCES Patios (Id)
        ON DELETE RESTRICT
) CHARACTER SET = utf8mb4;

-- ==========================================================
-- Índices
-- ==========================================================
CREATE INDEX IX_Funcionarios_PatioId ON Funcionarios (PatioId);
CREATE UNIQUE INDEX IX_Gerentes_FuncionarioId ON Gerentes (FuncionarioId);
CREATE UNIQUE INDEX IX_Gerentes_PatioId ON Gerentes (PatioId);

-- ==========================================================
-- Registros de Exemplo (opcional para testes)
-- ==========================================================
INSERT INTO Patios (Nome, Endereco) VALUES
  ('Pátio Centro', 'Rua Principal 123, São Paulo'),
  ('Pátio Zona Sul', 'Av. das Flores 456, São Paulo');

INSERT INTO Funcionarios (Nome, Email, Senha, PatioId) VALUES
  ('João da Silva', 'joao.silva@mottu.com', 'senha123', 1),
  ('Maria Oliveira', 'maria.oliveira@mottu.com', 'senha456', 2);

INSERT INTO Gerentes (FuncionarioId, PatioId) VALUES
  (1, 1);
