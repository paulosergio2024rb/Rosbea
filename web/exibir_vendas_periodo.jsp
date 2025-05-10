<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>

<%
    // Parâmetros da requisição
    String dataInicialStr = request.getParameter("data_inicial");
    String dataFinalStr   = request.getParameter("data_final");

    if (dataInicialStr == null || dataInicialStr.isEmpty() || 
        dataFinalStr == null || dataFinalStr.isEmpty()) {
        out.println("<h2>Por favor, selecione um período para filtrar.</h2>");
        return;
    }

    // Formatadores
    SimpleDateFormat sdf       = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat sdfExibir = new SimpleDateFormat("dd/MM/yyyy");
    DecimalFormat df           = new DecimalFormat("#,##0.00");
    
    // Objetos de banco de dados
    Connection con        = null;
    PreparedStatement ps  = null;
    ResultSet rs          = null;

    try {
        // Parse das datas
        Date dataInicial = sdf.parse(dataInicialStr);
        Date dataFinal   = sdf.parse(dataFinalStr);

        // Conexão com o banco
        Class.forName("org.mariadb.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");

        // Consulta SQL
        String sql = "SELECT rg, nome_do_cliente, cidade, " +
                     "pedido_id, DATE(data_pedido) AS data_pedido, observacoes, item_id, quantidade, " +
                     "preco_unitario, total_item, produto_codigo, produto_nome " +
                     "FROM view_relatorio_pedidos_vendas " +
                     "WHERE data_pedido >= ? AND data_pedido <= ? " +
                     "ORDER BY rg, pedido_id, item_id";

        ps = con.prepareStatement(sql);
        ps.setDate(1, new java.sql.Date(dataInicial.getTime()));
        ps.setDate(2, new java.sql.Date(dataFinal.getTime()));
        rs = ps.executeQuery();

        // Estrutura para agrupar por RG
        Map<String, List<Map<String, Object>>> clientesMap = new LinkedHashMap<>();
        double totalGeral = 0.0;

        while (rs.next()) {
            String rg = rs.getString("rg");
            
            if (!clientesMap.containsKey(rg)) {
                clientesMap.put(rg, new ArrayList<>());
            }
            
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("nome_do_cliente", rs.getString("nome_do_cliente"));
            item.put("cidade", rs.getString("cidade"));
            item.put("pedido_id", rs.getInt("pedido_id"));
            item.put("data_pedido", rs.getDate("data_pedido"));
            item.put("observacoes", rs.getString("observacoes"));
            item.put("item_id", rs.getInt("item_id"));
            
            // Tratamento de valores numéricos
            String quantidadeStr = rs.getString("quantidade");
            String totalItemStr = rs.getString("total_item");
            
            int quantidadeItem = 0;
            double totalItemValor = 0.0;

            try {
                quantidadeItem = (quantidadeStr != null && !quantidadeStr.isEmpty()) ? 
                                Integer.parseInt(quantidadeStr) : 0;
            } catch (NumberFormatException e) {}
            
            try {
                totalItemValor = (totalItemStr != null && !totalItemStr.isEmpty()) ? 
                                Double.parseDouble(totalItemStr) : 0.0;
            } catch (NumberFormatException e) {}
            
            item.put("quantidade", quantidadeItem);
            item.put("preco_unitario", rs.getDouble("preco_unitario"));
            item.put("total_item", totalItemValor);
            item.put("produto_codigo", rs.getString("produto_codigo"));
            item.put("produto_nome", rs.getString("produto_nome"));
            
            clientesMap.get(rg).add(item);
            totalGeral += totalItemValor;
        }

        // Cabeçalho da página com botão Voltar
        out.println("<div class='button-container'>");
        out.println("  <a href='filtrar_vendas_periodo.html' class='back-button'>← Voltar para Filtro</a>");
        out.println("</div>");
        
        out.println("<div class='header-container'>");
        out.println("<h2>Resultados da Filtragem</h2>");
        out.println("<div class='periodo'>Período: " + sdfExibir.format(dataInicial) + " a " + sdfExibir.format(dataFinal) + "</div>");
        out.println("</div>");
        
        if (clientesMap.isEmpty()) {
            out.println("<div class='no-results'>Nenhum resultado encontrado para o período selecionado.</div>");
        } else {
            // Iterar sobre cada cliente (agrupado por RG)
            for (Map.Entry<String, List<Map<String, Object>>> entry : clientesMap.entrySet()) {
                String rg = entry.getKey();
                List<Map<String, Object>> items = entry.getValue();
                
                if (!items.isEmpty()) {
                    // Dados do cliente
                    String nomeCliente = (String) items.get(0).get("nome_do_cliente");
                    String cidade = (String) items.get(0).get("cidade");
                    
                    out.println("<div class='cliente-card'>");
                    out.println("  <div class='cliente-header'>");
                    out.println("    <h3>" + nomeCliente + "</h3>");
                    out.println("    <div class='cliente-info'>");
                    out.println("      <span><strong>RG:</strong> " + rg + "</span>");
                    out.println("      <span><strong>Cidade:</strong> " + cidade + "</span>");
                    out.println("    </div>");
                    out.println("  </div>");
                    
                    // Tabela de itens do cliente
                    out.println("  <div class='table-container'>");
                    out.println("    <table>");
                    out.println("      <thead>");
                    out.println("        <tr>");
                    out.println("          <th>Pedido ID</th>");
                    out.println("          <th>Data</th>");
                    out.println("          <th>Observações</th>");
                    out.println("          <th>Item ID</th>");
                    out.println("          <th>Qtd</th>");
                    out.println("          <th>Preço Unit.</th>");
                    out.println("          <th>Total Item</th>");
                    out.println("          <th>Código</th>");
                    out.println("          <th>Produto</th>");
                    out.println("        </tr>");
                    out.println("      </thead>");
                    out.println("      <tbody>");
                    
                    double totalCliente = 0.0;
                    int totalQuantidadeCliente = 0;
                    
                    // Iterar sobre os itens do cliente
                    for (Map<String, Object> item : items) {
                        Date dataPedido = (Date) item.get("data_pedido");
                        double totalItem = (Double) item.get("total_item");
                        int quantidade = (Integer) item.get("quantidade");
                        
                        totalCliente += totalItem;
                        totalQuantidadeCliente += quantidade;
                        
                        out.println("        <tr>");
                        out.println("          <td>" + item.get("pedido_id") + "</td>");
                        out.println("          <td>" + (dataPedido != null ? sdfExibir.format(dataPedido) : "") + "</td>");
                        out.println("          <td>" + (item.get("observacoes") != null ? item.get("observacoes") : "") + "</td>");
                        out.println("          <td>" + item.get("item_id") + "</td>");
                        out.println("          <td>" + quantidade + "</td>");
                        out.println("          <td>R$ " + df.format(item.get("preco_unitario")) + "</td>");
                        out.println("          <td>R$ " + df.format(totalItem) + "</td>");
                        out.println("          <td>" + item.get("produto_codigo") + "</td>");
                        out.println("          <td>" + item.get("produto_nome") + "</td>");
                        out.println("        </tr>");
                    }
                    
                    out.println("      </tbody>");
                    out.println("    </table>");
                    out.println("  </div>");
                    
                    // Totais do cliente
                    out.println("  <div class='cliente-total'>");
                    out.println("    <div class='total-item'><span>Total Itens:</span> " + totalQuantidadeCliente + "</div>");
                    out.println("    <div class='total-value'><span>Total Cliente:</span> R$ " + df.format(totalCliente) + "</div>");
                    out.println("  </div>");
                    out.println("</div>");
                }
            }
            
            // Total geral
            out.println("<div class='grand-total'>");
            out.println("  <span>Total Geral:</span>");
            out.println("  <span>R$ " + df.format(totalGeral) + "</span>");
            out.println("</div>");
        }

    } catch (Exception e) {
        out.println("<div class='error-container'>");
        out.println("  <h2>Erro ao acessar o banco de dados:</h2>");
        out.println("  <p>" + e.getMessage() + "</p>");
        out.println("</div>");
        e.printStackTrace();
    } finally {
        // Fechamento de recursos
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (ps != null) ps.close(); } catch (Exception e) {}
        try { if (con != null) con.close(); } catch (Exception e) {}
    }
%>

<style>
    /* Estilos modernos */
    body {
        font-family: 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
        line-height: 1.6;
        color: #333;
        background-color: #f8f9fa;
        padding: 20px;
        max-width: 1200px;
        margin: 0 auto;
    }
    
    .button-container {
        margin-bottom: 20px;
    }
    
    .back-button {
        display: inline-block;
        background-color: #6c757d;
        color: white;
        padding: 8px 16px;
        border-radius: 4px;
        text-decoration: none;
        font-weight: 500;
        transition: background-color 0.3s;
    }
    
    .back-button:hover {
        background-color: #5a6268;
    }
    
    .header-container {
        background: #ffffff;
        padding: 20px;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        margin-bottom: 25px;
    }
    
    h2 {
        color: #2c3e50;
        margin: 0 0 10px 0;
        font-size: 1.8em;
    }
    
    .periodo {
        color: #7f8c8d;
        font-size: 0.95em;
    }
    
    .cliente-card {
        background: #ffffff;
        border-radius: 8px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.08);
        padding: 20px;
        margin-bottom: 30px;
    }
    
    .cliente-header {
        margin-bottom: 15px;
        padding-bottom: 15px;
        border-bottom: 1px solid #eee;
    }
    
    h3 {
        color: #2980b9;
        margin: 0 0 5px 0;
        font-size: 1.4em;
    }
    
    .cliente-info {
        display: flex;
        gap: 15px;
        font-size: 0.9em;
        color: #555;
    }
    
    .table-container {
        overflow-x: auto;
    }
    
    table {
        width: 100%;
        border-collapse: collapse;
        margin: 15px 0;
        font-size: 0.9em;
    }
    
    th {
        background-color: #3498db;
        color: white;
        text-align: left;
        padding: 12px 15px;
        font-weight: 500;
    }
    
    td {
        padding: 10px 15px;
        border-bottom: 1px solid #eee;
    }
    
    tr:nth-child(even) {
        background-color: #f8f9fa;
    }
    
    tr:hover {
        background-color: #f1f7fd;
    }
    
    .cliente-total {
        display: flex;
        justify-content: space-between;
        margin-top: 15px;
        padding-top: 15px;
        border-top: 1px solid #eee;
        font-weight: 600;
    }
    
    .grand-total {
        background: #2c3e50;
        color: white;
        padding: 15px 20px;
        border-radius: 8px;
        display: flex;
        justify-content: space-between;
        font-size: 1.1em;
        font-weight: 600;
        margin-top: 20px;
    }
    
    .no-results, .error-container {
        background: #ffffff;
        padding: 20px;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        text-align: center;
    }
    
    .error-container {
        background: #fdecea;
        border-left: 4px solid #f44336;
    }
    
    /* Botão voltar ao topo */
    #backToTop {
        position: fixed;
        bottom: 30px;
        right: 30px;
        width: 50px;
        height: 50px;
        background: #3498db;
        color: white;
        border: none;
        border-radius: 50%;
        cursor: pointer;
        display: none;
        font-size: 20px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.2);
        transition: all 0.3s;
    }
    
    #backToTop:hover {
        background: #2980b9;
        transform: translateY(-3px);
    }
    
    @media (max-width: 768px) {
        body {
            padding: 15px;
        }
        
        th, td {
            padding: 8px 10px;
        }
    }
</style>

<button id="backToTop" title="Voltar ao topo">↑</button>

<script>
    // Botão voltar ao topo
    const backToTopButton = document.getElementById("backToTop");
    
    window.addEventListener("scroll", () => {
        if (window.pageYOffset > 300) {
            backToTopButton.style.display = "block";
        } else {
            backToTopButton.style.display = "none";
        }
    });
    
    backToTopButton.addEventListener("click", () => {
        window.scrollTo({
            top: 0,
            behavior: "smooth"
        });
    });
</script>