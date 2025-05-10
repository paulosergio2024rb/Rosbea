<!DOCTYPE html>
<html>
<head>
    <title>Lista de Produtos Filtrados</title>
    <style>
        table {
            width: 80%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
        button {
            margin-top: 10px;
            padding: 8px 15px;
            cursor: pointer;
        }
    </style>
</head>
<body>

    <h1>Lista de Produtos Filtrados por Preço</h1>

    <table>
        <thead>
            <tr>
                <th>Nome do Produto</th>
            </tr>
        </thead>
        <tbody id="listaProdutos">
            </tbody>
    </table>

    <button onclick="window.print()">Imprimir</button>

    <button onclick="salvarArquivo()">Salvar em Arquivo</button>

    <script>
        function salvarArquivo() {
            alert("A funcionalidade de salvar em arquivo precisa ser implementada no servidor.");
        }
    </script>

</body>
</html>