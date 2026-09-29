-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 14-Maio-2026 às 00:14
-- Versão do servidor: 10.4.32-MariaDB
-- versão do PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `felixubershop`
--

  CREATE DATABASE felixubershop;

  USE felixubershop;
-- --------------------------------------------------------

--
-- Estrutura da tabela `carteira`
--

CREATE TABLE `carteira` (
  `id_carteira` int(11) NOT NULL,
  `id_utilizador` int(11) NOT NULL,
  `saldo` double NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `carteira`
--

INSERT INTO `carteira` (`id_carteira`, `id_utilizador`, `saldo`) VALUES
(1, 1, 0),
(2, 2, 0),
(3, 3, 0),
(100, 100, 0);

-- --------------------------------------------------------

--
-- Estrutura da tabela `encomenda`
--

CREATE TABLE `encomenda` (
  `id_encomenda` int(11) NOT NULL,
  `codigo_validacao` varchar(20) NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `data_encomenda` datetime NOT NULL DEFAULT current_timestamp(),
  `total` double NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `encomenda`
--



-- --------------------------------------------------------

--
-- Estrutura da tabela `linha_encomenda`
--

CREATE TABLE `linha_encomenda` (
  `id_linha` int(11) NOT NULL,
  `id_encomenda` int(11) NOT NULL,
  `id_produto` int(11) NOT NULL,
  `quantidade` int(11) NOT NULL,
  `preco_unitario` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `linha_encomenda`
--



-- --------------------------------------------------------

--
-- Estrutura da tabela `movimentos_carteira`
--

CREATE TABLE `movimentos_carteira` (
  `id_movimento` int(11) NOT NULL,
  `id_utilizador_op` int(11) DEFAULT NULL,
  `operacao` varchar(40) NOT NULL,
  `valor` double NOT NULL,
  `data_operacao` datetime NOT NULL DEFAULT current_timestamp(),
  `carteira_origem` int(11) DEFAULT NULL,
  `carteira_destino` int(11) DEFAULT NULL,
  `id_encomenda` int(11) DEFAULT NULL,
  `observacoes` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;



--
-- Estrutura da tabela `produto`
--

CREATE TABLE `produto` (
  `id_produto` int(11) NOT NULL,
  `nome` varchar(100) NOT NULL,
  `descricao` text DEFAULT NULL,
  `preco` double NOT NULL,
  `stock` int(11) NOT NULL DEFAULT 0,
  `categoria` varchar(50) NOT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `produto`
--

INSERT INTO `produto` (`id_produto`, `nome`, `descricao`, `preco`, `stock`, `categoria`, `ativo`) VALUES
(1, 'Maçã Royal Gala (kg)', 'Maçã fresca nacional', 1.49, 100, 'Frutas e Legumes',  1),
(2, 'Banana (kg)', 'Banana da Madeira', 1.29, 80, 'Frutas e Legumes',  1),
(3, 'Tomate Chucha (kg)', 'Tomate maduro para salada', 1.99, 50, 'Frutas e Legumes',  1),
(4, 'Alface Iceberg', 'Alface fresca, unidade', 0.89, 40, 'Frutas e Legumes',  1),
(5, 'Bife do Lombo (kg)', 'Carne de bovino nacional', 14.99, 20, 'Talho e Charcutaria',  1),
(6, 'Frango do Campo (kg)', 'Frango inteiro fresco', 5.49, 25, 'Talho e Charcutaria',  1),
(7, 'Pão de Mafra', 'Pão tradicional, 500g', 1.2, 60, 'Padaria e Pastelaria',  1),
(8, 'Croissant', 'Croissant de manteiga', 0.75, 100, 'Padaria e Pastelaria',  1),
(9, 'Água Luso 1.5L', 'Água mineral natural', 0.45, 200, 'Bebidas',  1),
(10, 'Cerveja Sagres 33cl', 'Pack 6 unidades', 3.99, 70, 'Bebidas',  1),
(11, 'Arroz Carolino 1kg', 'Arroz nacional', 1.19, 90, 'Mercearia',  1),
(12, 'Massa Esparguete 500g', 'Massa de trigo duro', 0.89, 119, 'Mercearia',  1),
(13, 'Azeite Virgem Extra 1L', 'Azeite português DOP', 7.99, 35, 'Mercearia',  1),
(14, 'Pizza Margherita Cong.', 'Pizza congelada 350g', 2.99, 40, 'Congelados',  1),
(15, 'Gelado Baunilha 1L', 'Gelado de baunilha', 4.49, 30, 'Congelados',  1),
(16, 'Leite Mimosa 1L', 'Leite meio-gordo', 0.99, 150, 'Laticínios',  1),
(17, 'Queijo da Serra', 'Queijo curado da Serra da Estrela', 8.99, 15, 'Laticínios',  1),
(18, 'Iogurte Natural (4un)', 'Pack 4 iogurtes naturais', 1.69, 60, 'Laticínios',  1),
(19, 'Detergente Roupa 3L', 'Para máquina de lavar', 6.49, 25, 'Limpeza e Higiene',  1),
(20, 'Lixívia 2L', 'Limpeza geral', 1.79, 50, 'Limpeza e Higiene',  1);

-- --------------------------------------------------------

--
-- Estrutura da tabela `promocao`
--

CREATE TABLE `promocao` (
  `id_promocao` int(11) NOT NULL,
  `titulo` varchar(100) NOT NULL,
  `mensagem` text NOT NULL,
  `data_inicio` date DEFAULT NULL,
  `data_fim` date DEFAULT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `promocao`
--

INSERT INTO `promocao` (`id_promocao`, `titulo`, `mensagem`, `data_inicio`, `data_fim`, `ativo`) VALUES
(1, 'Bem-vindo à FelixUberShop!', 'A sua mercearia de bairro, agora online. Encomende e levante quando quiser.', '2026-01-01', '2026-12-31', 1),
(2, 'Promoção de Abertura', '10% de desconto na primeira encomenda acima de 20€.', '2026-01-01', '2026-06-30', 1),
(3, 'Frutas e Legumes Frescos', 'Receção diária direta dos produtores nacionais.', '2026-01-01', '2026-12-31', 1);

-- --------------------------------------------------------

--
-- Estrutura da tabela `tipoutilizador`
--

CREATE TABLE `tipoutilizador` (
  `id_tipo` int(2) NOT NULL,
  `descricao` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `tipoutilizador`
--

INSERT INTO `tipoutilizador` (`id_tipo`, `descricao`) VALUES
(1, 'admin'),
(2, 'cliente'),
(4, 'cliente nao validado'),
(3, 'funcionario'),
(6, 'Utilizador apagado');

-- --------------------------------------------------------

--
-- Estrutura da tabela `utilizador`
--

CREATE TABLE `utilizador` (
  `id_utilizador` int(11) NOT NULL,
  `nomeUtilizador` varchar(40) NOT NULL,
  `mail` varchar(80) NOT NULL,
  `pass` varchar(100) NOT NULL,
  `telemovel` varchar(9) DEFAULT NULL,
  `tipoUtilizador` int(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `utilizador`
--

INSERT INTO `utilizador` (`id_utilizador`, `nomeUtilizador`, `mail`, `pass`, `telemovel`, `tipoUtilizador`) VALUES
(1, 'admin', 'admin@felixubershop.pt', '21232f297a57a5a743894a0e4a801fc3', '911111111', 1),
(2, 'funcionario', 'func@felixubershop.pt', 'cc7a84634199040d54376793842fe035', '922222222', 3),
(3, 'cliente', 'cliente@felixubershop.pt', '4983a0ab83ed86e0e7213c8783940193', '933333333', 2),
(100, 'felixubershop', 'felix@felixubershop.pt', '7baf5b9bbc58455809b7f660c7491554', '999999999', 1);

--
-- Acionadores `utilizador`
--
DELIMITER $$
CREATE TRIGGER `after_utilizador_insert` AFTER INSERT ON `utilizador` FOR EACH ROW BEGIN
  -- Só cria carteira se tipoUtilizador for diferente de 4 (cliente não validado) e 6 (apagado)
  IF NEW.tipoUtilizador NOT IN (4, 6) THEN
    IF NOT EXISTS (SELECT 1 FROM carteira WHERE id_utilizador = NEW.id_utilizador) THEN
      INSERT INTO carteira (id_utilizador, saldo) VALUES (NEW.id_utilizador, 0);
    END IF;
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_utilizador_update` AFTER UPDATE ON `utilizador` FOR EACH ROW BEGIN
  -- Se um utilizador passa de "não validado" para "cliente", cria-lhe carteira
  IF NEW.tipoUtilizador NOT IN (4, 6) THEN
    IF NOT EXISTS (SELECT 1 FROM carteira WHERE id_utilizador = NEW.id_utilizador) THEN
      INSERT INTO carteira (id_utilizador, saldo) VALUES (NEW.id_utilizador, 0);
    END IF;
  END IF;
END
$$
DELIMITER ;

--
-- Índices para tabelas despejadas
--

--
-- Índices para tabela `carteira`
--
ALTER TABLE `carteira`
  ADD PRIMARY KEY (`id_carteira`),
  ADD UNIQUE KEY `id_utilizador` (`id_utilizador`);

--
-- Índices para tabela `encomenda`
--
ALTER TABLE `encomenda`
  ADD PRIMARY KEY (`id_encomenda`),
  ADD UNIQUE KEY `codigo_validacao` (`codigo_validacao`),
  ADD KEY `id_cliente` (`id_cliente`);

--
-- Índices para tabela `linha_encomenda`
--
ALTER TABLE `linha_encomenda`
  ADD PRIMARY KEY (`id_linha`),
  ADD KEY `id_encomenda` (`id_encomenda`),
  ADD KEY `id_produto` (`id_produto`);

--
-- Índices para tabela `movimentos_carteira`
--
ALTER TABLE `movimentos_carteira`
  ADD PRIMARY KEY (`id_movimento`),
  ADD KEY `idx_mov_data` (`data_operacao`),
  ADD KEY `idx_mov_encomenda` (`id_encomenda`);

--
-- Índices para tabela `produto`
--
ALTER TABLE `produto`
  ADD PRIMARY KEY (`id_produto`),
  ADD KEY `categoria` (`categoria`);

--
-- Índices para tabela `promocao`
--
ALTER TABLE `promocao`
  ADD PRIMARY KEY (`id_promocao`);

--
-- Índices para tabela `tipoutilizador`
--
ALTER TABLE `tipoutilizador`
  ADD PRIMARY KEY (`id_tipo`),
  ADD UNIQUE KEY `descricao` (`descricao`);

--
-- Índices para tabela `utilizador`
--
ALTER TABLE `utilizador`
  ADD PRIMARY KEY (`id_utilizador`),
  ADD UNIQUE KEY `mail` (`mail`),
  ADD UNIQUE KEY `telemovel` (`telemovel`),
  ADD KEY `tipoUtilizador` (`tipoUtilizador`);

--
-- AUTO_INCREMENT de tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `carteira`
--
ALTER TABLE `carteira`
  MODIFY `id_carteira` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT de tabela `encomenda`
--
ALTER TABLE `encomenda`
  MODIFY `id_encomenda` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de tabela `linha_encomenda`
--
ALTER TABLE `linha_encomenda`
  MODIFY `id_linha` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de tabela `movimentos_carteira`
--
ALTER TABLE `movimentos_carteira`
  MODIFY `id_movimento` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de tabela `produto`
--
ALTER TABLE `produto`
  MODIFY `id_produto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT de tabela `promocao`
--
ALTER TABLE `promocao`
  MODIFY `id_promocao` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de tabela `tipoutilizador`
--
ALTER TABLE `tipoutilizador`
  MODIFY `id_tipo` int(2) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de tabela `utilizador`
--
ALTER TABLE `utilizador`
  MODIFY `id_utilizador` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=102;

--
-- Restrições para despejos de tabelas
--

--
-- Limitadores para a tabela `carteira`
--
ALTER TABLE `carteira`
  ADD CONSTRAINT `fk_carteira_utilizador` FOREIGN KEY (`id_utilizador`) REFERENCES `utilizador` (`id_utilizador`) ON DELETE CASCADE;

--
-- Limitadores para a tabela `encomenda`
--
ALTER TABLE `encomenda`
  ADD CONSTRAINT `fk_encomenda_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `utilizador` (`id_utilizador`);

--
-- Limitadores para a tabela `linha_encomenda`
--
ALTER TABLE `linha_encomenda`
  ADD CONSTRAINT `fk_linha_encomenda` FOREIGN KEY (`id_encomenda`) REFERENCES `encomenda` (`id_encomenda`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_linha_produto` FOREIGN KEY (`id_produto`) REFERENCES `produto` (`id_produto`);

--
-- Limitadores para a tabela `utilizador`
--
ALTER TABLE `utilizador`
  ADD CONSTRAINT `fk_utilizador_tipo` FOREIGN KEY (`tipoUtilizador`) REFERENCES `tipoutilizador` (`id_tipo`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
