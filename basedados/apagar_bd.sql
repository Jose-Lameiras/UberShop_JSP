-- =====================================================================
-- apagar_bd.sql
-- Script para eliminar todos os objetos relacionados com o projeto
-- FelixUberShop. Executar antes de re-correr o criar_bd.sql.
-- =====================================================================

-- Desativar a verificação de chaves estrangeiras para permitir DROP em qualquer ordem
SET FOREIGN_KEY_CHECKS = 0;

-- Apagar triggers (se a BD existir)
DROP TRIGGER IF EXISTS after_utilizador_insert;
DROP TRIGGER IF EXISTS after_utilizador_update;

-- Apagar a base de dados completa (remove todas as tabelas, índices, triggers e dados)
DROP DATABASE IF EXISTS felixubershop;

-- Reativar verificação de chaves estrangeiras
SET FOREIGN_KEY_CHECKS = 1;