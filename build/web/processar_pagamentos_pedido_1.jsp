<%@ page import="java.sql.*" %>
<%@ page import="java.util.Enumeration" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Processar Pagamentos do Pedido</title>
    <style>
        .mensagem {
            padding: 10px;
            margin: 5px 0;
            border-radius: 4px;
        }
        .mensagem.erro {
            background-color: #ffdddd;
            border-left: 4px solid #f44336;
        }
        .mensagem.sucesso {
            background-color: #ddffdd;
            border-left: 4px solid #4CAF50;
        }
        .mensagem.alerta {
            background-color: #ffffcc;
            border-left: 4px solid #ffeb3b;
        }
    </style>
</head>
<body>
    <h1>Processamento dos Pagamentos</h1>

    <%
    String nrPedidoPagamento = request.getParameter("nr_pedido");

    if (nrPedidoPagamento != null && !nrPedidoPagamento.isEmpty()) {
        String jdbcUrl = "jdbc:mariadb://localhost:3306/Rosbea";
        String dbUser = "paulo";
        String dbPassword = "6421";
        Connection connection = null;
        PreparedStatement preparedStatementUpdate = null;
        PreparedStatement psCaixa = null;
        int updatesRealizadas = 0;

        try {
            Class.forName("org.mariadb.jdbc.Driver");
            connection = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);
            connection.setAutoCommit(false);

            // Verifica se a coluna data_pagto existe
            boolean dataPagtoExists = false;
            try {
                DatabaseMetaData meta = connection.getMetaData();
                ResultSet columns = meta.getColumns(null, null, "vencimentos", "data_pagto");
                dataPagtoExists = columns.next();
                columns.close();
            } catch (SQLException e) {
                out.println("<div class='mensagem alerta'>⚠️ Aviso: Não foi possível verificar a coluna data_pagto: " + e.getMessage() + "</div>");
            }

            // VERIFICAÇÃO DO CAIXA ABERTO (NOVO BLOCO)
            int idCaixaAberto = 0;
            String sqlCaixa = "SELECT id_caixa FROM caixa WHERE status = 'aberto' LIMIT 1";
            try (PreparedStatement stmt = connection.prepareStatement(sqlCaixa);
                 ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    out.println("<div class='mensagem erro'>");
                    out.println("⚠️ ERRO: Não há caixa aberto. <a href='abrir_caixa.jsp'>Abrir caixa</a> antes de registrar pagamentos.");
                    out.println("</div>");
                    return;
                }
                idCaixaAberto = rs.getInt("id_caixa");
            }

            Enumeration<String> paramNames = request.getParameterNames();
            while (paramNames.hasMoreElements()) {
                String paramName = paramNames.nextElement();
                if (paramName.startsWith("pgto_")) {
                    try {
                        int idVencimento = Integer.parseInt(paramName.substring(5));
                        String valorPagoStr = request.getParameter(paramName);
                        double valorPago = 0.0;

                        if (valorPagoStr != null && !valorPagoStr.trim().isEmpty()) {
                            valorPagoStr = valorPagoStr.replace(",", ".");
                            valorPago = Double.parseDouble(valorPagoStr);
                        }

                        if (valorPago > 0) {
                            // Atualiza o vencimento (com data_pagto se existir)
                            String sqlUpdate;
                            if (dataPagtoExists) {
                                sqlUpdate = "UPDATE vencimentos SET pgto = ?, data_pagto = NOW() WHERE id = ? AND nr_pedido = ?";
                            } else {
                                sqlUpdate = "UPDATE vencimentos SET pgto = ? WHERE id = ? AND nr_pedido = ?";
                            }
                            
                            preparedStatementUpdate = connection.prepareStatement(sqlUpdate);
                            preparedStatementUpdate.setDouble(1, valorPago);
                            preparedStatementUpdate.setInt(2, idVencimento);
                            preparedStatementUpdate.setString(3, nrPedidoPagamento);
                            int rowsAffected = preparedStatementUpdate.executeUpdate();

                            if (rowsAffected > 0) {
                                // Registra a entrada no caixa (recebimento)
                                String sqlCaixaInsert = "INSERT INTO movimentacao_caixa " +
                                    "(id_caixa, tipo, valor, descricao, data_movimentacao, id_pedido) " +
                                    "VALUES (?, 'entrada', ?, ?, NOW(), ?)";
                                
                                psCaixa = connection.prepareStatement(sqlCaixaInsert);
                                psCaixa.setInt(1, idCaixaAberto);
                                psCaixa.setDouble(2, valorPago);
                                psCaixa.setString(3, "Recebimento do pedido " + nrPedidoPagamento + " (vencimento " + idVencimento + ")");
                                psCaixa.setString(4, nrPedidoPagamento);
                                psCaixa.executeUpdate();
                                
                                updatesRealizadas++;
                                out.println("<div class='mensagem sucesso'>✅ Pagamento de R$ " + 
                                    String.format("%.2f", valorPago) + " registrado com sucesso para o vencimento " + 
                                    idVencimento + " no pedido " + nrPedidoPagamento + ".</div>");
                            }
                        }
                    } catch (NumberFormatException e) {
                        connection.rollback();
                        out.println("<div class='mensagem erro'>⚠️ Erro ao interpretar o valor pago para o vencimento: " + 
                            request.getParameter(paramName) + "</div>");
                    } catch (SQLException e) {
                        connection.rollback();
                        out.println("<div class='mensagem erro'>⚠️ Erro ao atualizar o vencimento: " + e.getMessage() + "</div>");
                    } finally {
                        if (preparedStatementUpdate != null) preparedStatementUpdate.close();
                        if (psCaixa != null) psCaixa.close();
                    }
                }
            }

            connection.commit();
            
            if (updatesRealizadas > 0) {
                out.println("<div class='mensagem sucesso'>✅ " + updatesRealizadas + 
                    " pagamento(s) registrado(s) com sucesso para o pedido número: " + nrPedidoPagamento + ".</div>");
            } else {
                out.println("<div class='mensagem alerta'>⚠️ Nenhum pagamento foi registrado para o pedido número: " + 
                    nrPedidoPagamento + "</div>");
            }

        } catch (ClassNotFoundException e) {
            out.println("<div class='mensagem erro'>⚠️ Erro: Driver do MariaDB não encontrado.</div>");
        } catch (SQLException e) {
            try {
                if (connection != null) connection.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            out.println("<div class='mensagem erro'>⚠️ Erro de SQL geral: " + e.getMessage() + "</div>");
        } finally {
            try {
                if (connection != null) {
                    connection.setAutoCommit(true);
                    connection.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    } else {
        out.println("<div class='mensagem erro'>⚠️ Erro: Número do pedido não fornecido.</div>");
    }
    %>
    <br>
    <a href="buscar_pedido.jsp">Voltar para a Busca</a>
</body>
</html>