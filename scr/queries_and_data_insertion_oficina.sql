-- ============================================================================
-- DATA INSERTION
-- ============================================================================

use Oficina;

-- Inserindo Clientes no modelo Pai
insert into Cliente (Tipo_Cliente, Telefone, Endereco) values 
('PF', '(34) 99999-1111', 'Av. Afonso Pena, 1500 - Uberlândia'),
('PJ', '(34) 3232-2222', 'Rua Rondon Pacheco, 300 - Uberlândia'),
('PF', '(34) 98888-3333', 'Alameda dos Ipês, 45 - Uberlândia');

-- Inserindo Clientes PF
insert into Cliente_PF (CPF, Nome, Cliente_idCliente) values 
('11122233344', 'Victor Hugo', 1),
('55566677788', 'Maria Júlia', 3);

-- Inserindo Clientes PJ
insert into Cliente_PJ (CNPJ, Razao_Social, Inscricao_Estadual, Cliente_idCliente) values 
('12345678000199', 'Logística Avançada S.A.', 'MG-123.456.789', 2);

-- Inserindo Veículos
insert into Veiculo (Placa, Marca, Modelo, Ano, Cliente_idCliente) values 
('ABC1D23', 'Volkswagen', 'Golf GTI', 2021, 1),
('XYZ9W87', 'Mercedes-Benz', 'Sprinter', 2019, 2),
('MGO4E55', 'Chevrolet', 'Onix Turbo', 2023, 3);

-- Inserindo Equipes de Mecânicos
insert into Equipe_Mecanicos (Nome_Equipe) values 
('Equipe Alpha - Motores'),
('Equipe Beta - Elétrica e Alinhamento');

-- Inserindo Mecânicos
insert into Mecanico (Codigo, Nome, Endereco, Especialidade, Equipe_Mecanicos_idEquipe) values 
('MEC01', 'Carlos Souza', 'Rua Piauí, 12', 'Motores de Alta Performance', 1),
('MEC02', 'Fabio Lima', 'Av. Brasil, 99', 'Injeção Eletrônica', 1),
('MEC03', 'Roberto Dias', 'Rua Goiás, 450', 'Alinhamento e Suspensão', 2);

-- Inserindo Serviços
insert into Servico (Descricao, Valor_Mao_Obra) values 
('Revisão Geral do Motor', 450.00),
('Alinhamento e Balanceamento 3D', 150.00),
('Troca de Pastilhas de Freio', 120.00);

-- Inserindo Peças
insert into Peca (Codigo_Peca, Descricao, Valor_Unitario) values 
('PRT-101', 'Filtro de Óleo Sintético', 65.00),
('PRT-202', 'Jogo de Pastilhas Freio Brembo', 380.00),
('PRT-303', 'Óleo de Motor 5W30 (1L)', 55.00);

-- Inserindo Ordens de Serviço (OS)
insert into OS (idOS, Numero_OS, Data_Emissao, Data_Conclusao, Valor_Total, Status, Equipe_Mecanicos_idEquipe, Veiculo_idVeiculo, Veiculo_Cliente_idCliente) values 
(1, 1001, '2026-05-10 09:00:00', '2026-05-12 16:00:00', 1115.00, 'Finalizada', 1, 1, 1),
(2, 1002, '2026-05-20 14:30:00', null, 150.00, 'Em Andamento', 2, 2, 2),
(3, 1003, '2026-05-24 08:15:00', '2026-05-25 11:00:00', 395.00, 'Aprovada', 1, 3, 3);

-- Vinculando Serviços às OSs
insert into Itens_Servico_OS (Servico_idServico, OS_idOS, Quantidade, Valor_Cobrado) values 
(1, 1, 1, 450.00), -- OS 1001: Revisão Geral
(3, 1, 1, 120.00), -- OS 1001: Troca de Pastilhas
(2, 2, 1, 150.00), -- OS 1002: Alinhamento
(3, 3, 1, 120.00); -- OS 1003: Troca de Pastilhas

-- Vinculando Peças às OSs
insert into Itens_Peca_OS (OS_idOS, Quantidade, Valor_Unitario_Cobrado, Peca_idPeca) values 
(1, 1, 380.00, 2), -- 1 Jogo de Pastilhas Brembo
(1, 3, 55.00, 3),  -- 3 Litros de Óleo
(3, 1, 65.00, 1),  -- 1 Filtro de óleo
(3, 4, 55.00, 3);  -- 4 Litros de Óleo

-- ============================================================================
-- QUERIES SQL
-- ============================================================================

-- Qual o nome dos clientes PF, as placas de seus respectivos carros e o status de suas ordens de serviço?

select 
    pf.Nome as Nome_Cliente,
    v.Modelo as Modelo_Carro,
    v.Placa as Placa_Carro,
    os.Numero_OS,
    os.Status as Status_OS
from OS os
inner join Veiculo v on os.Veiculo_idVeiculo = v.idVeiculo
inner join Cliente c on v.Cliente_idCliente = c.idCliente
inner join Cliente_PF pf on c.idCliente = pf.Cliente_idCliente
where os.Status = 'Finalizada';

-- Qual o valor total faturado por OS considerando a soma dos serviços e das peças utilizadas?

select 
    os.Numero_OS,
    v.Placa as Placa_Veiculo,
    IFNULL(sum(distinct ios.Valor_Cobrado * ios.Quantidade), 0) as Total_Servicos,
    IFNULL(sum(iop.Valor_Unitario_Cobrado * iop.Quantidade), 0) as Total_Pecas,
    (IFNULL(sum(distinct ios.Valor_Cobrado * ios.Quantidade), 0) + 
     IFNULL(sum(iop.Valor_Unitario_Cobrado * iop.Quantidade), 0)) as Valor_Calculado_OS
from OS os
inner join Veiculo v on os.Veiculo_idVeiculo = v.idVeiculo
left join Itens_Servico_OS ios on os.idOS = ios.OS_idOS
left join Itens_Peca_OS iop on os.idOS = iop.OS_idOS
group by os.idOS, os.Numero_OS, v.Placa
order by Valor_Calculado_OS desc;

-- Quais equipes de mecânicos possuem mais de R$ 300,00 acumulados em serviços prestados nas OSs já finalizadas ou aprovadas?

select 
    em.Nome_Equipe,
    count(distinct os.idOS) as Qtd_Ordens_Atendidas,
    sum(ios.Valor_Cobrado * ios.Quantidade) as Total_Em_Servicos
from Equipe_Mecanicos em
inner join OS os on em.idEquipe = os.Equipe_Mecanicos_idEquipe
inner join Itens_Servico_OS ios on os.idOS = ios.OS_idOS
where os.Status in ('Finalizada', 'Aprovada')
group by em.idEquipe, em.Nome_Equipe
having Total_Em_Servicos > 300.00
order by Total_Em_Servicos desc;
