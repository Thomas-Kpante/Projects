//Code pris de "Annexe : Code source pour le serveur Node.js" du document word "Description"


const express = require("express");
const mysql = require("mysql2");
const path = require("path");
const cors = require("cors");
const multer = require("multer");
const fs = require("fs");
require('dotenv').config();
console.log(process.env);
console.log(process.env.DB_PASSWORD);
const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "delta",
  database: "dbproduitreactnodejs",
});

// ... (your connection event listeners)

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads");
  },
  filename: (req, file, cb) => {
    cb(null, `${req.body.productId}${path.extname(file.originalname)}`);
  },
});

const upload = multer({ storage: storage });

const app = express();
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname ,'uploads')));

app.post("/thumbnailUpload", upload.single("productThumbnail"), (req, res) => {
  try {
    console.log(req.file);
    return res.json({ data: req.file.filename });
  } catch (err) {
    res.json({ error: err.message });
  }
});

app.get("/produits", (req, res) => {
  console.log("get /produits");
  const q = "select * from tblproduit";
  db.query(q, (err, data) => {
    if (err) {
      console.log(err);
      return res.status(500).json({ error: err.sqlMessage });
    } else {
      console.log(data);
      return res.status(200).json(data);
    }
  });
});

app.post("/produits", (req, res) => {
  console.log("Received data:", req.body); // Log the received data
  const q = `insert into tblproduit(Description, Nom)
    values(?, ?)`;
  const values = [req.body.Description, req.body.Nom];
  console.log("Insert values:", values); // Log the values before querying
  db.query(q, values, (err, data) => {
    console.log(err, data);
    if (err) return res.json({ error: err.sqlMessage });
    else return res.json({ data });
  });
});


app.get("/produits/:productId", (req, res) => {
  const id = req.params.productId;
  const q = "SELECT * FROM tblproduit where id=?";
  db.query(q, [id], (err, data) => {
    console.log(err, data);
    if (err) return res.json({ error: err.sqlMessage });
    else return res.json({ data });
  });
});

app.put("/produits/:productId", (req, res) => {
  const id = req.params.productId;
  console.log("updated " + req.body);
  const data = req.body;
  const q = "update tblproduit set Nom=?, Description=? where id=?";
  console.log(q);
  db.query(q, [data.Nom, data.Description, id], (err, out) => {
    console.log(err, out);
    if (err) return res.json({ error: err.message });
    else {
      return res.json({ data: out });
    }
  });
});


app.delete("/produits/:productId", (req, res) => {
  const id = req.params.productId;
  console.log("deleting " + id, req.body);
  const q = `DELETE FROM tblproduit WHERE id= ?`;
  db.query(q, [id], (err, data) => {
    console.log(err, data);
    if (err) return res.json({ error: err.sqlMessage });
    else res.json({ data });
  });
});

app.listen(8080, () => {
  console.log("listening");
});
