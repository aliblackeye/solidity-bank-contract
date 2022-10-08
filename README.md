<h1 align="center">
  <a href="#"><img src="./Title.png" width="600"></a>
</h1>


<!-- <h3 class="project-name text-center" >Final Case Solution</h3> -->

<p align="center"><a href="https://www.akbanklab.com/tr/ana-sayfa" target="_blank">Akbank</a> Web3 Practicum için hazırlanmış minimalist bir Banka projesi.
</p>




<p align="center">

<a href="https://remix.ethereum.org/" target="_blank">
<img src="https://img.shields.io/badge/ide-remix-green"/>
</a>

<a href="https://opensource.org/licenses/" target="_blank">
<img src="https://img.shields.io/badge/dev-solidity-blue"/>
</a>

<a href="https://alikaragoz.tech" target="_blank">
<img src="https://img.shields.io/badge/site-alikaragoz.tech-blueviolet"/>
</a>

<a href="https://www.buymeacoffee.com/aliblackeye" target="_blank">
<img src="https://img.shields.io/badge/%24-donate-ff69b4"/>
</a>

</p>


<p align="center">
    <a href="#features">Özellikler</a> •
    <a href="#how-to-run">Nasıl Çalışır ?</a> •
    <a href="#learning">Kazanımlarım</a>
</div>

</p>

<div id="features"></div>

## Projedeki Özellikler

- Para çekme ve yatırma
- Bakiye bilgisini görüntüleme
- Başka bir hesaba Ethereum gönderme
- Total kullanıcı sayısını görüntüleme
- Yeni bir kullanıcı hesabı oluşturma
- Belirtilen adresteki kayıtlı kullanıcıyı görüntüleme
- Yapılan herhangi bir işlemden sonra event oluşturma

## Kullanılan Yapılar

- Function
- Mapping
- Array
- Constructor
- Struct
- Require
- Modifier
- Event

<div id="how-to-run"></div>

## Hazırlık

Kontratımızı yazmak için birkaç hazırlığa ihtiyacımız var.

```js 
  //SPDX-License-Identifier: MIT
  pragma solidity ^0.8.0;

  import "Counters.sol";
```

Lisans uyarısından kurtulmak için lisans belirtecimizi ve kontratımız için kullanacağımız solidity versiyonunu yazıyoruz.

Ardından güvenli blockhain uygulamaları yazmamız için standart haline gelmiş olan <a href="https://www.openzeppelin.com" target="_blank">OpenZeppelin</a> üzerinden Counters adlı kontratımızı import ediyoruz.

Counters kontratı bize artırılabilen, azaltılabilen veya sıfırlanabilen bir sayaç sağlar. Eğer isterseniz sıfırdan kendiniz yazmayı da tercih edebilirsiniz. Bu kontratı, oluşturacağımız bankadaki kullanıcılara ID atamak için kullanacağız.

<hr>

## Başlayalım

```js 
  contract Bank {

    using Counters for Counters.Counter;
    Counters.Counter private idToUser;

    struct User {
        uint256 ID;
        uint256 balance;
        uint256 debt;
    }
  }
```

Import ettiğimiz Counters kontratının içindeki Counter struct'ından varsayılan değeri 0 olan _value değişkenine ulaşıyoruz. Bu değişken bizim sayacımız olacak.

Ardından oluşturacağımız kullanıcılar için User adında bir struct oluşturuyorum. Kullanıcılarımızı birbirinden ayırmak için ID(kimlik), bakiye bilgilerini tutmak için balance değişkenini oluşturuyoruz.  

uint ya da uint256 tipindeki değişkenler ile sadece pozitif sayıları tutmak istediğimizi belirtiyoruz.
<hr>

## Event (Olay Tetikçisi)

```js 
  event Withdraw(address creator, uint256 amount);
  event Deposit(address creator, uint256 amount);
  event Transfer(address sender, address to, uint256 amount);
  event Account(uint256 id, address creator, address createdAt);
```

Biliyorsunuz ki bankamızda para gönderme, para yatırma gibi belirli işlemler yapacağız. Bu işlemler sonunda hangi olayın kimin tarafından gerçekleştiğini bilmek ve bu olayların takibini sağlamak için olay tetikçilerini kullanırız.

Para çekme için Withdraw, para yatırma için Deposit,
bütün transfer işlemleri için Transfer ve tüm hesap işlemleri için Account adında event oluşturdum.

Daha detaylı takip sağlamak için daha fazla event oluşturabilirsiniz.

<hr>

## Tanımlamalar

```js
  address payable owner;
  address[] private userAccounts;
  mapping(address => User) private users;
```

Kontratımızı çalıştıran kişinin adresini tutmak için owner değişkeni oluşturduk. Bu adresin payable yani ödeme ile ilgili işlemleri gerçekleştirebilir bir adres olduğunu belirttik. 

Banka kullanıcılarımızın adreslerini liste halinde tutan bir array tanımlıyoruz.

Yapısı itibariyle sözlüğe benzeyen mapping ile hangi adresin hangi kullanıcıya işaret ettiğini tutan users adında bir mapping tanımlıyoruz.
 
<hr>

## Constructor (Yapıcı)

```js
  constructor() {
      owner = payable(msg.sender);
      idToUser.increment();
      users[msg.sender] = User(idToUser.current(), 0, 0); 
      userAccounts.push(msg.sender); 
      idToUser.increment(); 
  }
```

Biliyoruz ki kontrat çalıştırıldığı gibi bazı işlemlerin tamamlanması lazım. Mesela kontratı çalıştırdığımız anda biz hiçbir şey yapmadan owner değişkeninin bizim adresimize eşit olduğunu, ilk kullanıcının biz olduğunu ve userAccounts array'ine de adresimizin eklenmesi gerektiğini biliyoruz.

Bu yüzden kontrat deploy edildiği gibi çalışan bir fonksiyona ihtiyacımız var. O yapı da yapıcı fonksiyon olan constructor oluyor.

ID'leri 0'dan değil, 1 den başlayacak şekilde tutmak istediğim için önce 1 arttırıyorum.

<hr>

## Bazı Gereksinimler

```js
  modifier isOwner() {
      require(owner == msg.sender, "You are not owner!");
      _;
  }

  modifier insufficientBalance(uint256 _amount) {
      require(
          _amount > 0 && _amount <= users[msg.sender].balance,
          "Error: Insufficient balance!"
      );
      _;
  }
```

Solidity dilinde tekrar tekrar kullanmamız gereken kodlarımızı tekrar tekrar kopyala yapıştır yapıp okumayı zorlaştırmamak ve dosyamızın boyutunu artırmamak için modifier'ları kullanırız.

isOwner ile yapılan işlemin bizim tarafımızdan(owner) olup olmadığını,
insufficientBalance ile bakiyenin yetersiz olduğu durumları kontrol ederiz.

<hr>

## Yeni Kullanıcı Oluşturmak

```js
  function createNewUser(address _address) external {
      require(
          users[_address].ID == 0,
          "Error: This user has already registered!"
      ); 

      users[_address] = User(idToUser.current(), 0, 0); 
      userAccounts.push(_address); 
      idToUser.increment(); 
       emit Account(idToUser.current(), msg.sender, _address); 
  }
```

Biliyoruz ki tanımladığımız User struct'ındaki ID'yi uint olarak tanımladık. Eğer uint değişkenlere bir atama yapılmaz ise varsayılan değeri 0'dır. Mantıken parametre olarak belirttiğimiz adrese sahip bir kullanıcı yok ise ID'si 0 olacaktır. Böylece artık kullanıcının varlığının kontrolünü sağlayabiliriz. Eğer şartlar sağlanıyor ise belirtilen adreste yeni bir kullanıcı oluşturulur.

İşlemler bittikten sonra kullanıcı ile ilgili bir olay gerçekleştirdiğimiz için bu olayı bildirmemiz gerekiyor. Emit(yaymak) ile olayı bildiriyoruz.

<hr>

## Kullanıcı Sayısı

```js
  function totalUsers() external view returns (uint256) {
      return userAccounts.length;
  }
```

Şu ana kadar kaç kullanıcının kayıtlı olduğunu görmek için oluşturduğumuz userAccounts array'inin uzunluğunu döndürüyoruz.



<hr>

## Para Yatırma

```js
  function deposit() external payable isOwner {
      users[msg.sender].balance += msg.value;
      emit Deposit(msg.sender, msg.value);
  }
```

isOwner modifier'ı ile önce sahiplik kontrolü yapıyoruz. Şartlar sağlanırsa belirttiğimiz kadar bakiye cüzdanımızdan bankamızdaki cüzdanımıza aktarılır.

<hr>

## Para Çekme

```js
  function withdraw(uint256 _amount)
      external
      isOwner
      insufficientBalance(_amount)
  {
      users[msg.sender].balance -= _amount; 
      emit Withdraw(msg.sender, _amount); 

      (bool sent, ) = msg.sender.call{value: _amount}("Sent");
      require(sent, "Failed to send ETH");
}
```

Önce isOwner modifier'ı ile sahiplik kontrolünü, sonrasında ise insufficientBalance modifier'ı ile çekeceğimiz miktarın bakiyeden fazla olmamasını ve 0'dan büyük olmasını kontrol ediyoruz. Şartlar sağlanırsa para çekilir ve event oluşturulur. Para çekilemezse hata mesajı verilir.

<hr>

## Para Transferi
```js
  function sendMoney(address _address, uint256 _amount)
      external
      isOwner
      insufficientBalance(_amount)
  {
      require(
          _address != msg.sender,
          "Error: You can't send money to yourself"
      );
      require(users[_address].ID != 0, "Error: User not found!");

      users[msg.sender].balance -= _amount;
      users[_address].balance += _amount;

      emit Transfer(msg.sender, _address, _amount);
  }
```

Para transferi yapmak için yine sahiplik ve miktar kontrolü yapıktan sonra ek olarak, parayı bankada kayıtlı olan başka bir kullanıcıya gönderip göndermediğimizi kontrol ederiz. Çünkü kendimize para göndermemiz mantıklı olmaz.

<hr>

## Bakiye Görüntüleme

```js
  function getBalance() external view returns (uint256) {
      return users[msg.sender].balance;
  }
```

Bakiyemizde ne kadar bulunduğunu görüntülemek için getBalance fonksiyonu çağıran adresin bakiyesini döndürüyoruz.

<hr>

## Bir Kullanıcının Bilgisi
```js
  function getUser(address _address)
      external
      view
      returns (User memory user)
  {
      return users[_address];
  }
```

Kontratın düzgün çalışıp çalışmadığını kontrol etmek için başka bir kullanıcının bilgilerini görüntüleyebileceğimiz fonksiyon yazıyoruz. Zaten bu kontratı gerçek hayatta kullanmayacağız.


<hr>

<div id="learning"></div>

## Kazanımlarım

Bu practicum sayesinde Web 3.0 dünyasını araştırarak Non Fungible ve Fungible Token arasındaki farkı öğrendim. NFT'lerin satıldığı pazar alanlarını ve Blockchain'in işleyiş mantığını öğrendim. Solidity dilinin söz dizimini ve fonksiyonlar, struct vb. yapılarını kullanarak öğrendim.

<hr>

## Destek Ol

<a href="https://www.buymeacoffee.com/aliblackeye" target="_blank"><img class="support-img" src="https://cdn.buymeacoffee.com/buttons/v2/default-violet.png" alt="Buy Me A Coffee" style="height: 50px !important;width: 181px !important;" ></a>

