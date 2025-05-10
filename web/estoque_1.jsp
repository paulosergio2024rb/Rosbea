<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="pt-BR">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Resultados da Busca</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 20px;
                background-color: #f5f5f5;
            }
            .container {
                max-width: 1400px;
                margin: 0 auto;
                background-color: white;
                padding: 20px;
                border-radius: 8px;
                box-shadow: 0 0 10px rgba(0,0,0,0.1);
            }
            h1 {
                color: #333;
                text-align: center;
            }
            .search-info {
                margin-bottom: 20px;
                padding: 15px;
                background-color: #e9f7ef;
                border-radius: 5px;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 20px;
                font-size: 14px;
            }
            th, td {
                border: 1px solid #ddd;
                padding: 10px;
                text-align: left;
            }
            th {
                background-color: #4CAF50;
                color: white;
            }
            tr:nth-child(even) {
                background-color: #f2f2f2;
            }
            .back-link {
                display: inline-block;
                margin-top: 20px;
                padding: 10px 15px;
                background-color: #4CAF50;
                color: white;
                text-decoration: none;
                border-radius: 4px;
            }
            .back-link:hover {
                background-color: #45a049;
            }
            .saldo-positivo {
                color: green;
                font-weight: bold;
            }
            .saldo-negativo {
                color: red;
                font-weight: bold;
            }
            .no-results {
                text-align: center;
                padding: 20px;
                font-style: italic;
                color: #666;
            }
            .error {
                color: red;
                font-weight: bold;
                padding: 10px;
                background-color: #ffeeee;
                border-radius: 5px;
            }
            .sort-options {
                margin: 15px 0;
                text-align: right;
            }
            .sort-options a {
                margin-left: 10px;
                color: #4CAF50;
                text-decoration: none;
            }
            .sort-options a:hover {
                text-decoration: underline;
            }
            .sort-options a.active {
                font-weight: bold;
                color: #2E7D32;
            }
            .number {
                text-align: right;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Controle de Estoque</h1>

            <%
                // Parâmetros com tratamento seguro
                String tipoBusca = request.getParameter("tipo_busca");
                String termoBusca = request.getParameter("termo_busca");
                String ordenacao = request.getParameter("ordenacao");

                // Valores padrão
                if (tipoBusca == null) {
                    tipoBusca = "todos";
                }
                if (termoBusca == null) {
                    termoBusca = "";
                }
                if (ordenacao == null) {
                    ordenacao = "nome";
                }

                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;

                try {
                    Class.forName("org.mariadb.jdbc.Driver");
                    conn = DriverManager.getConnection(
                            "jdbc:mariadb://localhost:3306/Rosbea",
                            "paulo",
                            "6421");

                    // Construir SQL base com as novas colunas
                    String sql = "SELECT produto_id, nome_produto, ml_produto, embalagem, total_vendido, total_comprado, saldo_estoque "
                            + "FROM vw_controle_estoqueml";

                    // Adicionar WHERE conforme tipo de busca
                    if (!"todos".equals(tipoBusca)) {
                        sql += " WHERE ";
                        if ("codigo".equals(tipoBusca)) {
                            sql += "produto_id = ?";
                        } else if ("nome".equals(tipoBusca)) {
                            sql += "nome_produto LIKE ?";
                        }
                    }

                    // Adicionar ORDER BY conforme seleção
                    switch (ordenacao) {
                        case "saldo_asc":
                            sql += " ORDER BY saldo_estoque ASC";
                            break;
                        case "saldo_desc":
                            sql += " ORDER BY saldo_estoque DESC";
                            break;
                        default:
                            sql += " ORDER BY nome_produto";
                    }

                    // Preparar statement
                    pstmt = conn.prepareStatement(sql);

                    // Definir parâmetros se necessário
                    if (!"todos".equals(tipoBusca) && termoBusca != null && !termoBusca.trim().isEmpty()) {
                        if ("codigo".equals(tipoBusca)) {
                            pstmt.setString(1, termoBusca.trim());
                        } else {
                            pstmt.setString(1, "%" + termoBusca.trim() + "%");
                        }
                    }

                    // Executar consulta
                    rs = pstmt.executeQuery();
            %>

            <div class="search-info">
                <p><strong>Modo de exibição:</strong> 
                    <%= "todos".equals(tipoBusca) ? "Todos os produtos"
                        : "codigo".equals(tipoBusca) ? "Por código" : "Por nome"%>
                </p>
                <% if (!"todos".equals(tipoBusca)) {%>
                <p><strong>Termo pesquisado:</strong> <%= termoBusca%></p>
                <% }%>
                <p><strong>Ordenação:</strong> 
                    <%= "saldo_asc".equals(ordenacao) ? "Saldo crescente"
                        : "saldo_desc".equals(ordenacao) ? "Saldo decrescente" : "Nome do produto"%>
                </p>
            </div>

            <div class="sort-options">
                Ordenar por: 
                <a href="estoque.jsp?tipo_busca=<%= tipoBusca%>&termo_busca=<%= termoBusca%>&ordenacao=nome" 
                   class="<%= "nome".equals(ordenacao) ? "active" : ""%>">Nome</a>
                <a href="estoque.jsp?tipo_busca=<%= tipoBusca%>&termo_busca=<%= termoBusca%>&ordenacao=saldo_asc" 
                   class="<%= "saldo_asc".equals(ordenacao) ? "active" : ""%>">Saldo ↑</a>
                <a href="estoque.jsp?tipo_busca=<%= tipoBusca%>&termo_busca=<%= termoBusca%>&ordenacao=saldo_desc" 
                   class="<%= "saldo_desc".equals(ordenacao) ? "active" : ""%>">Saldo ↓</a>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>Código</th>
                        <th>Nome do Produto</th>
                        <th>ML</th>
                        <th>Embalagem</th>
                        <th>Total Vendido (ml)</th>
                        <th>Total Comprado</th>
                        <th>Saldo em Estoque</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        boolean encontrouResultados = false;
                        while (rs.next()) {
                            encontrouResultados = true;
                            int saldoEstoque = rs.getInt("saldo_estoque");
                            String classeSaldo = saldoEstoque >= 0 ? "saldo-positivo" : "saldo-negativo";
                    %>
                    <tr>
                        <td><%= rs.getString("produto_id")%></td>
                        <td><%= rs.getString("nome_produto")%></td>
                        <td class="number"><%= rs.getInt("ml_produto")%> ml</td>
                        <td class="number"><%= rs.getInt("embalagem")%></td>
                        <td class="number"><%= rs.getInt("total_vendido")%> ml</td>
                        <td class="number"><%= rs.getInt("total_comprado")%></td>
                        <td class="number <%= classeSaldo%>"><%= saldoEstoque%></td>
                    </tr>
                    <%
                        }

                        if (!encontrouResultados) {
                    %>
                    <tr>
                        <td colspan="7" class="no-results">Nenhum produto encontrado com os critérios de busca informados.</td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>

            <%
                } catch (Exception e) {
                    out.println("<div class='error'>");
                    out.println("<h3>Erro durante a busca:</h3>");
                    out.println("<p>" + e.getMessage() + "</p>");
                    out.println("</div>");
                    e.printStackTrace();
                } finally {
                    if (rs != null) try { rs.close(); } catch (SQLException e) {}
                    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                    if (conn != null) try { conn.close(); } catch (SQLException e) {}
                }
            %>

            <a href="controle_estoque.html" class="back-link">Nova Busca</a>
        </div>
    </body>
</html>