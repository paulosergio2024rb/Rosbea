<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.SQLException"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt-br">
    <head>
        <meta charset="UTF-8">
        <title>Alteração de Produto</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
        <style>
            :root {
                --primary-color: #1976d2;
                --secondary-color: #0d47a1;
                --accent-color: #4fc3f7;
                --warning-color: #ff9800;
                --light-gray: #f5f5f5;
                --medium-gray: #e0e0e0;
                --dark-gray: #757575;
            }

            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }

            body {
                font-family: 'Roboto', sans-serif;
                line-height: 1.6;
                color: #333;
                background-color: #f9f9f9;
                display: flex;
                justify-content: center;
                align-items: center;
                min-height: 100vh;
                padding: 20px;
            }

            .result-container {
                background: white;
                border-radius: 8px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.1);
                padding: 30px;
                width: 100%;
                max-width: 600px;
                text-align: center;
            }

            .result-header h1 {
                color: var(--primary-color);
                font-size: 1.8rem;
                margin-bottom: 20px;
                display: flex;
                justify-content: center;
                align-items: center;
                gap: 10px;
            }

            .message-box {
                padding: 20px;
                background-color: #e3f2fd;
                border-left: 4px solid var(--primary-color);
                border-radius: 4px;
                font-size: 1.1rem;
                color: var(--dark-gray);
                text-align: left;
                margin-top: 20px;
            }
        </style>
    </head>
    <body>
        <div class="result-container">
            <div class="result-header">
                <h1><i class="fas fa-check-circle"></i> Resultado da Alteração</h1>
            </div>
            <div class="message-box">
                <%
                    // Variáveis para os parâmetros
                    Integer codigo = null, codigo_barbearia = null, barbearia = null, ml = null,
                            saldo_minimo = null, lista_preco = null, embalagem = null, premio_barber = null;
                    String nome = null, inspirado = null, codigo_fornecedor = null, genero = null,
                            ativo = null, fornecedor = null;
                    Double preco = null, preco_de_custo = null, preco_dolar = null;

                    try {
                        // Conversão dos parâmetros com validação
                        String codigoStr = request.getParameter("codigo");
                        if (codigoStr != null && !codigoStr.trim().isEmpty()) {
                            codigo = Integer.parseInt(codigoStr);
                        }

                        // Repetir o mesmo padrão para todos os campos numéricos
                        String codigoBarbeariaStr = request.getParameter("codigo_barbearia");
                        if (codigoBarbeariaStr != null && !codigoBarbeariaStr.trim().isEmpty()) {
                            codigo_barbearia = Integer.parseInt(codigoBarbeariaStr);
                        }

                        // Campos de texto
                        nome = request.getParameter("nome");
                        inspirado = request.getParameter("inspirado");
                        // ... outros campos de texto

                        // Campos decimais
                        String precoStr = request.getParameter("preco");
                        if (precoStr != null && !precoStr.trim().isEmpty()) {
                            preco = Double.parseDouble(precoStr);
                        }
                        // ... outros campos decimais

                        // Validação dos campos obrigatórios
                        if (codigo == null) {
                            throw new Exception("Código do produto é obrigatório");
                        }

                        // Conexão com o banco de dados
                        Connection conecta = null;
                        PreparedStatement st = null;

                        try {
                            Class.forName("org.mariadb.jdbc.Driver");
                            conecta = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");

                            String sql = "UPDATE produto SET codigo_barbearia = ?, barbearia = ?, ml = ?, "
                                    + "saldo_minimo = ?, lista_preco = ?, embalagem = ?, premio_barber = ?, "
                                    + "nome = ?, inspirado = ?, codigo_fornecedor = ?, genero = ?, ativo = ?, "
                                    + "fornecedor = ?, preco = ?, preco_de_custo = ?, preco_dolar = ? "
                                    + "WHERE codigo = ?";

                            st = conecta.prepareStatement(sql);

                            // Definir os parâmetros
                            st.setObject(1, codigo_barbearia);
                            st.setObject(2, barbearia);
                            st.setObject(3, ml);
                            st.setObject(4, saldo_minimo);
                            st.setObject(5, lista_preco);
                            st.setObject(6, embalagem);
                            st.setObject(7, premio_barber);
                            st.setString(8, nome);
                            st.setString(9, inspirado);
                            st.setString(10, codigo_fornecedor);
                            st.setString(11, genero);
                            st.setString(12, ativo);
                            st.setString(13, fornecedor);
                            st.setObject(14, preco);
                            st.setObject(15, preco_de_custo);
                            st.setObject(16, preco_dolar);
                            st.setInt(17, codigo);

                            int linhasAfetadas = st.executeUpdate();

                            if (linhasAfetadas > 0) {
                                out.print("✅ Os dados do produto <strong>" + codigo + "</strong> foram alterados com sucesso.");
                            } else {
                                out.print("⚠️ Nenhum produto foi atualizado. Verifique se o código existe.");
                            }

                        } catch (ClassNotFoundException e) {
                            out.print("❌ Erro: Driver do banco de dados não encontrado.");
                        } catch (SQLException e) {
                            out.print("❌ Erro no banco de dados: " + e.getMessage());
                        } finally {
                            if (st != null) try {
                                st.close();
                            } catch (SQLException ignore) {
                            }
                            if (conecta != null) try {
                                conecta.close();
                            } catch (SQLException ignore) {
                            }
                        }

                    } catch (NumberFormatException e) {
                        out.print("❌ Erro: Um dos campos numéricos contém valor inválido.");
                    } catch (Exception e) {
                        out.print("❌ Erro: " + e.getMessage());
                    }
                %>
            </div>
        </div>
        <a href="index.jsp" class="btn-voltar">
            <i class="fas fa-arrow-left"></i> Voltar ao Início
        </a>
    </body>
</html>
