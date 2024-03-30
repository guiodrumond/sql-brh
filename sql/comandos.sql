
-- Inserir novo colaborador

INSERT INTO brh.colaborador (matricula, nome, cpf, salario, departamento, cep, logradouro, complemento_endereco)
    VALUES ('AA123', 'Catarina', '222.333.444-55', '10000', 'DEPTI', '71111-100', 'Avenida das Pirambóias', 'Apto 233');

INSERT INTO brh.telefone_colaborador (colaborador, numero, tipo)
    VALUES ('AA123', '(61) 9 9999-9999', 'M');

INSERT INTO brh.telefone_colaborador (colaborador, numero, tipo)
    VALUES ('AA123', '(61) 3030-4040', 'R');

INSERT INTO brh.email_colaborador (colaborador, email, tipo)
    VALUES ('AA123', 'catarina@email.com', 'P');

INSERT INTO brh.email_colaborador (colaborador, email, tipo)
    VALUES ('AA123', 'catarina.cat@brh.com', 'T');

INSERT INTO brh.dependente (cpf, colaborador, nome, parentesco, data_nascimento)
    VALUES ('123.123.123-44', 'AA123', 'Melissa', 'Filho(a)', to_date('2020-01-01', 'yyyy-mm-dd'));

INSERT INTO brh.dependente (cpf, colaborador, nome, parentesco, data_nascimento)
    VALUES ('124.124.124-44', 'AA123', 'Samantha', 'Cônjuge', to_date('1980-01-01', 'yyyy-mm-dd'));

INSERT INTO brh.papel (id, nome) VALUES (8, 'Especialista de Negócios');

INSERT INTO brh.projeto (id, nome, responsavel, inicio, fim) VALUES (5, 'BI', 'AA123', to_date('2023-01-01', 'yyyy-mm-dd'), null);

INSERT INTO brh.atribuicao (projeto, colaborador, papel) VALUES (5, 'AA123', 8);


-- Atualizar cadastro de colaborador

-- Checar como está o registro antes da mudança
SELECT nome FROM brh.colaborador
	WHERE matricula = 'M123';
SELECT email FROM brh.email_colaborador
	WHERE colaborador = 'M123';

-- Alterar o nome do colaborador
UPDATE brh.colaborador
	SET nome = 'Maria Mendonça'
	WHERE matricula = 'M123';

-- Alterar o e-mail do colaborador
UPDATE brh.email_colaborador
	SET email = 'maria.mendonca@email.com'
	WHERE colaborador = 'M123' AND tipo = 'P';

-- Checar como ficou o registro após a mudança
SELECT nome FROM brh.colaborador
	WHERE matricula = 'M123';
SELECT email FROM brh.email_colaborador
	WHERE colaborador = 'M123';


-- Relatório de cônjuges

SELECT colaborador AS matricula , nome, data_nascimento FROM brh.dependente
	WHERE parentesco = 'Cônjuge';


-- Relatório de contatos telefônicos

SELECT colaborador AS matricula, numero FROM brh.telefone_colaborador
	WHERE tipo <> 'R'
	ORDER BY colaborador, numero;


-- Excluir departamento SECAP

-- Checando os colaboradores que vão ser dispensados
SELECT * FROM brh.colaborador
    WHERE departamento = 'SECAP';

-- Excluíndo registros de contatos
DELETE FROM brh.telefone_colaborador
	WHERE colaborador IN (
	SELECT * FROM brh.colaborador
    	WHERE departamento = 'SECAP');
DELETE FROM brh.email_colaborador
	WHERE colaborador IN (
	SELECT * FROM brh.colaborador
    	WHERE departamento = 'SECAP');
DELETE FROM brh.dependente
	WHERE colaborador IN (
	SELECT * FROM brh.colaborador
    	WHERE departamento = 'SECAP');

-- Excluindo os registros dos colaboradores dispensados
DELETE FROM brh.colaborador
	WHERE departamento = 'SECAP';

-- Excluindo o registro do departamento extinto
DELETE FROM brh.departamento
	WHERE sigla = 'SECAP';

-- Checando se os registros foram excluídos
SELECT * FROM brh.colaborador
    WHERE departamento = 'SECAP';


-- Relatório de departamentos

SELECT departamento AS sigla, nome FROM brh.colaborador
	WHERE cep = '71777-700' AND departamento IN ('SECAP', 'SESEG')
	ORDER BY departamento;


--- SEMANA 3


-- Filtrar dependentes

SELECT C.NOME AS NOME_COLABORADOR, D.NOME AS NOME_DEPENDENTE, D.DATA_NASCIMENTO
FROM BRH.DEPENDENTE D
INNER JOIN BRH.COLABORADOR C
ON C.MATRICULA = D.COLABORADOR
WHERE
D.NOME LIKE '%h%' OR
TO_CHAR(D.DATA_NASCIMENTO,'MM') IN ('04', '05', '06')
ORDER BY C.NOME, D.NOME
;


-- Listar colaborador com maior salário

SELECT NOME, SALARIO
FROM BRH.COLABORADOR
WHERE ROWNUM = 1
ORDER BY SALARIO DESC
;



-- Relatório de senioridade

SELECT MATRICULA, NOME, SALARIO,
CASE
WHEN SALARIO <= 3000 THEN 'Júnior'
WHEN SALARIO BETWEEN 3000.01 AND 6000 THEN 'Pleno'
WHEN SALARIO BETWEEN 6000.01 AND 20000 THEN 'Sênior'
ELSE 'Corpo diretor'
END AS SENIORIDADE
FROM BRH.COLABORADOR
ORDER BY SENIORIDADE, NOME
;



-- Listar quantidade de colaboradores em projetos

SELECT D.NOME, P.NOME, COUNT(C.MATRICULA) AS QUANTIDADE_COLABORADORES
FROM BRH.PROJETO P
INNER JOIN BRH.ATRIBUICAO A
ON P.ID = A.PROJETO
INNER JOIN BRH.COLABORADOR C
ON A.COLABORADOR = C.MATRICULA
INNER JOIN BRH.DEPARTAMENTO D
ON D.SIGLA = C.DEPARTAMENTO
GROUP BY D.NOME, P.NOME
ORDER BY D.NOME, P.NOME
;


-- Listar colaboradores com mais dependentes

SELECT C.NOME, COUNT(D.COLABORADOR) AS QUANTIDADE_DEPENDENTES
FROM BRH.COLABORADOR C
INNER JOIN BRH.DEPENDENTE D
ON C.MATRICULA = D.COLABORADOR
GROUP BY C.NOME
HAVING COUNT(D.COLABORADOR) > 1
ORDER BY QUANTIDADE_DEPENDENTES DESC, C.NOME
;



-- Relatório analítico de equipes

SELECT
D.NOME AS DEPARTAMENTO,
CH.NOME AS CHEFE,
CO.NOME AS COLABORADOR,
PR.NOME AS PROJETO,
PA.NOME AS PAPEL,
T.NUMERO AS TELEFONE,
DEP.NOME AS DEPENDENTE
FROM BRH.ATRIBUICAO A
INNER JOIN BRH.PROJETO PR
ON A.PROJETO = PR.ID
INNER JOIN BRH.PAPEL PA
ON A.PAPEL = PA.ID
INNER JOIN BRH.COLABORADOR CO
ON A.COLABORADOR = CO.MATRICULA
INNER JOIN BRH.DEPARTAMENTO D
ON CO.DEPARTAMENTO = D.SIGLA
INNER JOIN BRH.COLABORADOR CH
ON D.CHEFE = CH.MATRICULA
INNER JOIN BRH.TELEFONE_COLABORADOR T
ON CO.MATRICULA = T.COLABORADOR
INNER JOIN BRH.DEPENDENTE DEP
ON CO.MATRICULA = DEP.COLABORADOR
ORDER BY PROJETO, COLABORADOR, DEPENDENTE
;



-- Listar faixa etária dos dependentes

SELECT
CPF,
NOME,
TO_CHAR(DATA_NASCIMENTO, 'DD/MM/YYYY') AS "DATA DE NASCIMENTO",
PARENTESCO,
COLABORADOR,
TRUNC(MONTHS_BETWEEN(SYSDATE, DATA_NASCIMENTO)/12) AS IDADE,
CASE
WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, DATA_NASCIMENTO)/12) < 18 THEN 'Menor de idade'
ELSE 'Maior de idade'
END AS "FAIXA ETÁRIA"
FROM BRH.DEPENDENTE
ORDER BY COLABORADOR, NOME
;



-- Paginar listagem de colaboradores




-- Relatório de plano de saúde

SELECT C.MATRICULA, C.NOME, C.SALARIO,
CASE
WHEN C.SALARIO <= 3000 THEN 'Júnior'
WHEN C.SALARIO BETWEEN 3000.01 AND 6000 THEN 'Pleno'
WHEN C.SALARIO BETWEEN 6000.01 AND 20000 THEN 'Sênior'
ELSE 'Corpo diretor'
END AS SENIORIDADE,
CASE
WHEN SALARIO <= 3000 THEN 0.001 * C.SALARIO
WHEN SALARIO BETWEEN 3000.01 AND 6000 THEN 0.002 * C.SALARIO
WHEN SALARIO BETWEEN 6000.01 AND 20000 THEN 0.003 * C.SALARIO
ELSE 0.005 * C.SALARIO
END AS PERCENTUAL_SAUDE
FROM BRH.COLABORADOR C
INNER JOIN BRH.DEPENDENTE D
ON C.MATRICULA = D.COLABORADOR
GROUP BY C.NOME
;





Nenhum ficheiro selecionado
Accepted file types are plain text files and SQLite3 databases, maximal file size is 1 MB.
Format SQL
Options: Show plain text | Copy to clipboard | Print result
-- Inserir novo colaborador

INSERT INTO brh.colaborador (matricula, nome, cpf, salario, departamento, cep, logradouro, complemento_endereco)
VALUES ('AA123', 'Catarina', '222.333.444-55', '10000', 'DEPTI', '71111-100', 'Avenida das Pirambóias', 'Apto 233');


INSERT INTO brh.telefone_colaborador (colaborador, numero, tipo)
VALUES ('AA123', '(61) 9 9999-9999', 'M');


INSERT INTO brh.telefone_colaborador (colaborador, numero, tipo)
VALUES ('AA123', '(61) 3030-4040', 'R');


INSERT INTO brh.email_colaborador (colaborador, email, tipo)
VALUES ('AA123', 'catarina@email.com', 'P');


INSERT INTO brh.email_colaborador (colaborador, email, tipo)
VALUES ('AA123', 'catarina.cat@brh.com', 'T');


INSERT INTO brh.dependente (cpf, colaborador, nome, parentesco, data_nascimento)
VALUES ('123.123.123-44', 'AA123', 'Melissa', 'Filho(a)', to_date('2020-01-01', 'yyyy-mm-dd'));


INSERT INTO brh.dependente (cpf, colaborador, nome, parentesco, data_nascimento)
VALUES ('124.124.124-44', 'AA123', 'Samantha', 'Cônjuge', to_date('1980-01-01', 'yyyy-mm-dd'));


INSERT INTO brh.papel (id, nome)
VALUES (8, 'Especialista de Negócios');


INSERT INTO brh.projeto (id, nome, responsavel, inicio, fim)
VALUES (5, 'BI', 'AA123', to_date('2023-01-01', 'yyyy-mm-dd'), NULL);


INSERT INTO brh.atribuicao (projeto, colaborador, papel)
VALUES (5, 'AA123', 8);

-- Atualizar cadastro de colaborador
 -- Checar como está o registro antes da mudança

SELECT nome
FROM brh.colaborador
WHERE matricula = 'M123';


SELECT email
FROM brh.email_colaborador
WHERE colaborador = 'M123';

-- Alterar o nome do colaborador

UPDATE brh.colaborador
SET nome = 'Maria Mendonça'
WHERE matricula = 'M123';

-- Alterar o e-mail do colaborador

UPDATE brh.email_colaborador
SET email = 'maria.mendonca@email.com'
WHERE colaborador = 'M123'
  AND tipo = 'P';

-- Checar como ficou o registro após a mudança

SELECT nome
FROM brh.colaborador
WHERE matricula = 'M123';


SELECT email
FROM brh.email_colaborador
WHERE colaborador = 'M123';

-- Relatório de cônjuges

SELECT colaborador AS matricula,
       nome,
       data_nascimento
FROM brh.dependente
WHERE parentesco = 'Cônjuge';

-- Relatório de contatos telefônicos

SELECT colaborador AS matricula,
       numero
FROM brh.telefone_colaborador
WHERE tipo <> 'R'
ORDER BY colaborador,
         numero;

-- Excluir departamento SECAP
 -- Checando os colaboradores que vão ser dispensados

SELECT *
FROM brh.colaborador
WHERE departamento = 'SECAP';

-- Excluíndo registros de contatos

DELETE
FROM brh.telefone_colaborador
WHERE colaborador IN
    (SELECT *
     FROM brh.colaborador
     WHERE departamento = 'SECAP');


DELETE
FROM brh.email_colaborador
WHERE colaborador IN
    (SELECT *
     FROM brh.colaborador
     WHERE departamento = 'SECAP');


DELETE
FROM brh.dependente
WHERE colaborador IN
    (SELECT *
     FROM brh.colaborador
     WHERE departamento = 'SECAP');

-- Excluindo os registros dos colaboradores dispensados

DELETE
FROM brh.colaborador
WHERE departamento = 'SECAP';

-- Excluindo o registro do departamento extinto

DELETE
FROM brh.departamento
WHERE sigla = 'SECAP';

-- Checando se os registros foram excluídos

SELECT *
FROM brh.colaborador
WHERE departamento = 'SECAP';

-- Relatório de departamentos

SELECT departamento AS sigla,
       nome
FROM brh.colaborador
WHERE cep = '71777-700'
  AND departamento IN ('SECAP',
                       'SESEG')
ORDER BY departamento;

--- SEMANA 3
 -- Filtrar dependentes

SELECT C.NOME AS NOME_COLABORADOR,
       D.NOME AS NOME_DEPENDENTE,
       D.DATA_NASCIMENTO
FROM BRH.DEPENDENTE D
INNER JOIN BRH.COLABORADOR C ON C.MATRICULA = D.COLABORADOR
WHERE D.NOME LIKE '%h%'
  OR TO_CHAR(D.DATA_NASCIMENTO, 'MM') IN ('04',
                                          '05',
                                          '06')
ORDER BY C.NOME,
         D.NOME ;

-- Listar colaborador com maior salário

SELECT NOME,
       SALARIO
FROM BRH.COLABORADOR
WHERE ROWNUM = 1
ORDER BY SALARIO DESC ;

-- Relatório de senioridade

SELECT MATRICULA,
       NOME,
       SALARIO,
       CASE
           WHEN SALARIO <= 3000 THEN 'Júnior'
           WHEN SALARIO BETWEEN 3000.01 AND 6000 THEN 'Pleno'
           WHEN SALARIO BETWEEN 6000.01 AND 20000 THEN 'Sênior'
           ELSE 'Corpo diretor'
       END AS SENIORIDADE
FROM BRH.COLABORADOR
ORDER BY SENIORIDADE,
         NOME ;

-- Listar quantidade de colaboradores em projetos

SELECT D.NOME,
       P.NOME,
       COUNT(C.MATRICULA) AS QUANTIDADE_COLABORADORES
FROM BRH.PROJETO P
INNER JOIN BRH.ATRIBUICAO A ON P.ID = A.PROJETO
INNER JOIN BRH.COLABORADOR C ON A.COLABORADOR = C.MATRICULA
INNER JOIN BRH.DEPARTAMENTO D ON D.SIGLA = C.DEPARTAMENTO
GROUP BY D.NOME,
         P.NOME
ORDER BY D.NOME,
         P.NOME ;

-- Listar colaboradores com mais dependentes

SELECT C.NOME,
       COUNT(D.COLABORADOR) AS QUANTIDADE_DEPENDENTES
FROM BRH.COLABORADOR C
INNER JOIN BRH.DEPENDENTE D ON C.MATRICULA = D.COLABORADOR
GROUP BY C.NOME
HAVING COUNT(D.COLABORADOR) > 1
ORDER BY QUANTIDADE_DEPENDENTES DESC,
         C.NOME ;

-- Relatório analítico de equipes

SELECT D.NOME AS DEPARTAMENTO,
       CH.NOME AS CHEFE,
       CO.NOME AS COLABORADOR,
       PR.NOME AS PROJETO,
       PA.NOME AS PAPEL,
       T.NUMERO AS TELEFONE,
       DEP.NOME AS DEPENDENTE
FROM BRH.ATRIBUICAO A
INNER JOIN BRH.PROJETO PR ON A.PROJETO = PR.ID
INNER JOIN BRH.PAPEL PA ON A.PAPEL = PA.ID
INNER JOIN BRH.COLABORADOR CO ON A.COLABORADOR = CO.MATRICULA
INNER JOIN BRH.DEPARTAMENTO D ON CO.DEPARTAMENTO = D.SIGLA
INNER JOIN BRH.COLABORADOR CH ON D.CHEFE = CH.MATRICULA
INNER JOIN BRH.TELEFONE_COLABORADOR T ON CO.MATRICULA = T.COLABORADOR
INNER JOIN BRH.DEPENDENTE DEP ON CO.MATRICULA = DEP.COLABORADOR
ORDER BY PROJETO,
         COLABORADOR,
         DEPENDENTE ;

-- Listar faixa etária dos dependentes

SELECT CPF,
       NOME,
       TO_CHAR(DATA_NASCIMENTO, 'DD/MM/YYYY') AS "DATA DE NASCIMENTO",
       PARENTESCO,
       COLABORADOR,
       TRUNC(MONTHS_BETWEEN(SYSDATE, DATA_NASCIMENTO)/12) AS IDADE,
       CASE
           WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, DATA_NASCIMENTO)/12) < 18 THEN 'Menor de idade'
           ELSE 'Maior de idade'
       END AS "FAIXA ETÁRIA"
FROM BRH.DEPENDENTE
ORDER BY COLABORADOR,
         NOME ;

-- Paginar listagem de colaboradores
 -- Relatório de plano de saúde

SELECT C.MATRICULA,
       C.NOME,
       C.SALARIO,
       CASE
           WHEN C.SALARIO <= 3000 THEN 'Júnior'
           WHEN C.SALARIO BETWEEN 3000.01 AND 6000 THEN 'Pleno'
           WHEN C.SALARIO BETWEEN 6000.01 AND 20000 THEN 'Sênior'
           ELSE 'Corpo diretor'
       END AS SENIORIDADE,
       CASE
           WHEN SALARIO <= 3000 THEN 0.001 * C.SALARIO
           WHEN SALARIO BETWEEN 3000.01 AND 6000 THEN 0.002 * C.SALARIO
           WHEN SALARIO BETWEEN 6000.01 AND 20000 THEN 0.003 * C.SALARIO
           ELSE 0.005 * C.SALARIO
       END AS PERCENTUAL_SAUDE
FROM BRH.COLABORADOR C
INNER JOIN BRH.DEPENDENTE D ON C.MATRICULA = D.COLABORADOR
GROUP BY C.NOME ;