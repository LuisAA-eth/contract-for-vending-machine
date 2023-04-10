// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;


contract VendingMachine{

/*  PROPIEDADES DEL CONTRATO
1) Solo el propietario puede añadir productos nuevos
2) Solo el propietario puede reponer productos
3) Solo el propietario puede acceder al balance de la maquina
4) Cualquiera puede comprar productos
5) Solo el propietario puede traspasar el saldo de la maquina a su cuenta

*/

  address payable private owner;


 struct Snack {
      uint32 id;  // Identificador del producto
      string name;  //Nombre del produto
      uint32 quantity;  // Cantidad de producto
      uint price;   //Precio del producto

 }
   // Eventos
     event AddSnack(string _name , uint32 _quantity);
     event RecargarSnack(string _name , uint32 _quantity);
     event SnackSold(string _name , uint32 _amount);



    Snack [] Stock;   // Array de stock de productos
    uint8 public TotalSnacks;  // Total de snack en maquina

 constructor (){
   owner = payable (msg.sender);
   TotalSnacks = 0;
 }


   modifier onlyOwner (){
    require(msg.sender == owner);
    _;
    }


    // VER PRODUCTOS
  function GetAllSnack () external view returns (Snack [] memory _stock)
  {
     return Stock;

  }
  

   // aGREGAR PRODUCTOS A LA MAQUINA
  function AddNewSnack(string memory _name , uint32 _quantity , uint _price) external onlyOwner {
    require(bytes(_name).length != 0 , "Tienes que agregar un nombre valido");
    require(_quantity != 0 , "Tienes que agregar una cantidad de productos valida");
    require(_price != 0 , "Tienes que agregar un precio correcto");

    for (uint8 i = 0; i < Stock.length; i++){

        require(!CompareString(_name, Stock[i].name));
    }
       Snack memory newSnack = Snack (TotalSnacks , _name , _quantity , _price*10^18);
       Stock.push(newSnack);
       TotalSnacks++;

       emit AddSnack(_name , _quantity);

  }

     // Recargar productos a la maquina
   function ReStock (uint32 _id , uint32 _quantity) external  onlyOwner {
       require(_quantity != 0 , "Tienes que agregar una cantidad correcta");
       require(_id <= Stock.length , "Tienes que seleccionar un ID de producto correcto");
       Stock[_id].quantity += _quantity;
       emit RecargarSnack(Stock[_id].name, Stock[_id].quantity);

   }

     // Obtener el balance de la maquina
    function GetBalanceMachine () external view onlyOwner returns (uint){

      return address(this).balance;

    }

     // Retirar el dinero de la maquina
   function Retiro () external onlyOwner{

       owner.transfer(address(this).balance);
   }

     // Comprar productos 
   function ComprarSnack(uint32 _id , uint32 _amount) external payable {
        require(_amount != 0 , "Tienes que agregar una cantidad correcta");
        require(Stock[_id].quantity >= _amount ,"No hay disponibilidad suficiente de este producto");
        require(msg.value >= Stock[_id].price , "Dinero insuficiente para comprar este producto");
        Stock[_id].quantity -= _amount;
        emit SnackSold(Stock[_id].name, _amount);

   }


    // Funcion para comparar string
  function CompareString (string memory a , string memory b) internal pure returns (bool){

      return (keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b)));
  }


}