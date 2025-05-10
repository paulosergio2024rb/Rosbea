<%@ page import="java.sql.*" %>
<%@ page import="java.util.Enumeration" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Processar Pagamentos do Pedido</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f4f4f4;
        }
        .mensagem {
            padding: 15px;
            margin: 15px 0;
            border-radius: 4px;
            border-left: 5px solid;
        }
        .mensagem.erro {
            background-color: #ffebee;
            border-color: #f44336;
            color: #c62828;
        }
        .mensagem.sucesso {
            background-color: #e8f5e9;
            border-color: #4CAF50;
            color: #2e7d32;
        }
        .mensagem.alerta {
            background-color: #fff8e1;
            border-color: #ffc107;
            color: #ff8f00;
        }
        .mensagem.info {
            background-color: #e3f2fd;
            border-color: #2196F3;
            color: #1565c0;
        }
        .resumo {
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            margin: 20px 0;
        }
        .resumo h3 {
            margin-top: 0;
            color: #333;
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
        }
        .resumo-item {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
        }
        .resumo-valor {
            font-weight: bold;
        }
        a {
            display: inline-block;
            margin-top: 20px;
            padding: 10px 15px;
            background-color: #2196F3;
            color: white;
            text-decoration: none;
            border-radius: 4px;
        }
        a:hover {
            background-color: #0b7dda;
        }
    </style>
</head>
<body>
    <h1>Processamento dos Pagamentos</h1>

    <%
    String nrPedidoPagamento = request.getParameter("nr_pedido");
    double totalPagamentos = 0;
    double totalDescontos = 0;

    if (nrPedidoPagamento != null && !nrPedidoPagamento.isEmpty()) {
        String jdbcUrl = "jdbc:mariadb://localhost:3306/Rosbea";
        String dbUser = "paulo";
        String dbPassword = "6421";
        Connection connection = null;
        PreparedStatement preparedStatementUpdate = null;
        PreparedStatement psCaixa = null;
        PreparedStatement psCheckVencimento = null;
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

            // VERIFICAÇÃO DO CAIXA ABERTO
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
                
                if (paramName.startsWith("pgto_") || paramName.startsWith("desconto_")) {
                    try {
                        boolean isPagamento = paramName.startsWith("pgto_");
                        int idVencimento = Integer.parseInt(paramName.substring(isPagamento ? 5 : 9));
                        
                        // Verifica se já processamos este vencimento (para evitar duplicação com desconto)
                        if (isPagamento) {
                            // Primeiro verifica se o vencimento existe e obtém os valores atuais
                            String sqlCheck = "SELECT valor_parcela, pgto, desconto FROM vencimentos WHERE id = ? AND nr_pedido = ?";
                            psCheckVencimento = connection.prepareStatement(sqlCheck);
                            psCheckVencimento.setInt(1, idVencimento);
                            psCheckVencimento.setString(2, nrPedidoPagamento);
                            ResultSet rsCheck = psCheckVencimento.executeQuery();
                            
                            if (!rsCheck.next()) {
                                out.println("<div class='mensagem alerta'>⚠️ Vencimento " + idVencimento + " não encontrado para o pedido " + nrPedidoPagamento + "</div>");
                                continue;
                            }
                            
                            double valorParcela = rsCheck.getDouble("valor_parcela");
                            double valorPagoAtual = rsCheck.getDouble("pgto");
                            double descontoAtual = rsCheck.getDouble("desconto");
                            
                            // Processa pagamento
                            String valorPagoStr = request.getParameter(paramName);
                            double valorPago = 0.0;

                            if (valorPagoStr != null && !valorPagoStr.trim().isEmpty()) {
                                valorPagoStr = valorPagoStr.replace(",", ".");
                                valorPago = Double.parseDouble(valorPagoStr);
                            }

                            if (valorPago > 0) {
                                double novoTotalPago = valorPagoAtual + valorPago;
                                double valorMaximoPermitido = valorParcela - descontoAtual;
                                
                                if (novoTotalPago > valorMaximoPermitido) {
                                    out.println("<div class='mensagem erro'>⚠️ Erro no vencimento " + idVencimento + 
                                        ": O valor pago (R$ " + String.format("%.2f", novoTotalPago) + 
                                        ") excede o valor permitido (R$ " + String.format("%.2f", valorMaximoPermitido) + ")</div>");
                                    continue;
                                }
                                
                                // Atualiza o vencimento (com data_pagto se existir)
                                String sqlUpdate;
                                if (dataPagtoExists) {
                                    sqlUpdate = "UPDATE vencimentos SET pgto = pgto + ?, data_pagto = NOW() WHERE id = ? AND nr_pedido = ?";
                                } else {
                                    sqlUpdate = "UPDATE vencimentos SET pgto = pgto + ? WHERE id = ? AND nr_pedido = ?";
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
                                    
                                    totalPagamentos += valorPago;
                                    updatesRealizadas++;
                                    out.println("<div class='mensagem sucesso'>✅ Pagamento de R$ " + 
                                        String.format("%.2f", valorPago) + " registrado com sucesso para o vencimento " + 
                                        idVencimento + " no pedido " + nrPedidoPagamento + ".</div>");
                                }
                            }
                        } else {
                            // Processa desconto
                            String valorDescontoStr = request.getParameter(paramName);
                            double valorDesconto = 0.0;

                            if (valorDescontoStr != null && !valorDescontoStr.trim().isEmpty()) {
                                valorDescontoStr = valorDescontoStr.replace(",", ".");
                                valorDesconto = Double.parseDouble(valorDescontoStr);
                            }

                            if (valorDesconto > 0) {
                                // Primeiro verifica o valor atual da parcela e pagamentos
                                String sqlCheck = "SELECT valor_parcela, pgto FROM vencimentos WHERE id = ? AND nr_pedido = ?";
                                psCheckVencimento = connection.prepareStatement(sqlCheck);
                                psCheckVencimento.setInt(1, idVencimento);
                                psCheckVencimento.setString(2, nrPedidoPagamento);
                                ResultSet rsCheck = psCheckVencimento.executeQuery();
                                
                                if (rsCheck.next()) {
                                    double valorParcela = rsCheck.getDouble("valor_parcela");
                                    double valorPagoAtual = rsCheck.getDouble("pgto");
                                    
                                    // Verifica se o desconto + pagamentos não excede o valor da parcela
                                    if ((valorDesconto + valorPagoAtual) > valorParcela) {
                                        out.println("<div class='mensagem erro'>⚠️ Erro no vencimento " + idVencimento + 
                                            ": O desconto (R$ " + String.format("%.2f", valorDesconto) + 
                                            ") somado aos pagamentos (R$ " + String.format("%.2f", valorPagoAtual) + 
                                            ") excede o valor da parcela (R$ " + String.format("%.2f", valorParcela) + ")</div>");
                                        continue;
                                    }
                                    
                                    // Atualiza o desconto no vencimento
                                    String sqlUpdateDesconto = "UPDATE vencimentos SET desconto = ? WHERE id = ? AND nr_pedido = ?";
                                    preparedStatementUpdate = connection.prepareStatement(sqlUpdateDesconto);
                                    preparedStatementUpdate.setDouble(1, valorDesconto);
                                    preparedStatementUpdate.setInt(2, idVencimento);
                                    preparedStatementUpdate.setString(3, nrPedidoPagamento);
                                    int rowsAffected = preparedStatementUpdate.executeUpdate();

                                    if (rowsAffected > 0) {
                                        totalDescontos += valorDesconto;
                                        out.println("<div class='mensagem sucesso'>✅ Desconto de R$ " + 
                                            String.format("%.2f", valorDesconto) + " aplicado com sucesso para o vencimento " + 
                                            idVencimento + " no pedido " + nrPedidoPagamento + ".</div>");
                                    }
                                }
                            }
                        }
                    } catch (NumberFormatException e) {
                        out.println("<div class='mensagem erro'>⚠️ Erro ao interpretar o valor para o vencimento " + 
                            paramName.substring(paramName.startsWith("pgto_") ? 5 : 9) + ": " + 
                            request.getParameter(paramName) + "</div>");
                    } catch (SQLException e) {
                        out.println("<div class='mensagem erro'>⚠️ Erro ao atualizar o vencimento: " + e.getMessage() + "</div>");
                    } finally {
                        if (preparedStatementUpdate != null) preparedStatementUpdate.close();
                        if (psCaixa != null) psCaixa.close();
                        if (psCheckVencimento != null) psCheckVencimento.close();
                    }
                }
            }

            connection.commit();
            
            if (updatesRealizadas > 0 || totalDescontos > 0) {
                out.println("<div class='resumo'>");
                out.println("<h3>Resumo das Atualizações</h3>");
                out.println("<div class='resumo-item'><span>Número do Pedido:</span><span class='resumo-valor'>" + nrPedidoPagamento + "</span></div>");
                out.println("<div class='resumo-item'><span>Total de Pagamentos:</span><span class='resumo-valor'>R$ " + String.format("%.2f", totalPagamentos) + "</span></div>");
                out.println("<div class='resumo-item'><span>Total de Descontos:</span><span class='resumo-valor'>R$ " + String.format("%.2f", totalDescontos) + "</span></div>");
                out.println("<div class='resumo-item'><span>Valor Líquido:</span><span class='resumo-valor'>R$ " + String.format("%.2f", (totalPagamentos + totalDescontos)) + "</span></div>");
                out.println("</div>");
                
                out.println("<div class='mensagem sucesso'>✅ " + updatesRealizadas + 
                    " pagamento(s) e " + (totalDescontos > 0 ? "1 desconto" : "0 descontos") + 
                    " registrado(s) com sucesso para o pedido número: " + nrPedidoPagamento + ".</div>");
            } else {
                out.println("<div class='mensagem alerta'>⚠️ Nenhum pagamento ou desconto foi registrado para o pedido número: " + 
                    nrPedidoPagamento + "</div>");
            }

        } catch (ClassNotFoundException e) {
            out.println("<div class='mensagem erro'>⚠️ Erro: Driver do MariaDB não encontrado.</div>");
        } catch (SQLException e) {
            try {
                if (connection != null) connection.rollback();
                out.println("<div class='mensagem erro'>⚠️ Erro de SQL geral: " + e.getMessage() + "</div>");
            } catch (SQLException ex) {
                out.println("<div class='mensagem erro'>⚠️ Erro ao realizar rollback: " + ex.getMessage() + "</div>");
            }
        } finally {
            try {
                if (connection != null) {
                    connection.setAutoCommit(true);
                    connection.close();
                }
            } catch (SQLException e) {
                out.println("<div class='mensagem alerta'>⚠️ Erro ao fechar conexão: " + e.getMessage() + "</div>");
            }
        }
    } else {
        out.println("<div class='mensagem erro'>⚠️ Erro: Número do pedido não fornecido.</div>");
    }
    %>
    
    <div class='mensagem info'>
        <strong>Atenção:</strong> Verifique se todos os pagamentos foram registrados corretamente no caixa.
    </div>
    
    <a href="buscar_pedido.jsp?nr_pedido=<%= nrPedidoPagamento != null ? nrPedidoPagamento : "" %>">Voltar para o Pedido</a>
    <a href="caixa.jsp" style="margin-left: 10px;">Ir para o Caixa</a>
</body>
</html>