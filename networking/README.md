# Networking

Bu calismada Docker container ile host makine arasindaki temel network ve port mantigini uygulamali olarak inceledim.

## HTTP Server

Ubuntu container icerisinde basit bir HTTP server baslatmak icin:

```bash
python3 -m http.server 8080
```

komutunu kullandim.

Bu komut Python'un hazir `http.server` modulunu kullanarak bir HTTP server baslatti. Server 8080 portundan gelen istekleri dinlemeye basladi.

## Baglantiyi Test Etme

Server'a ulasip ulasamadigimi kontrol etmek icin container icerisinde:

```bash
curl localhost:8080
```

komutunu kullandim.

HTML cevabi almam server'in calistigini ve container icerisinden 8080 portuna ulasabildigimi gosterdi.

## Host ve Container

Daha sonra ayni istegi Mac uzerinden:

```bash
curl localhost:8080
```

ile gondermeyi denedim fakat baglanti kurulamadi.

Bunun nedeni HTTP server'in container icerisinde calismasi ve container'in 8080 portunun host makineye acilmamis olmasiydi.

## Port Mapping

Container'i bu kez:

```bash
docker run -it -p 8080:8080 ubuntu bash
```

komutuyla baslattim.

Buradaki port mapping mantigi:

```text
-p HOST_PORT:CONTAINER_PORT
```

seklindedir.

Bu calismada:

```text
Mac :8080 -> Container :8080 -> Python HTTP Server
```

baglantisi olustu.

Bundan sonra Mac uzerinden:

```bash
curl localhost:8080
```

komutunu tekrar calistirdigimda HTTP server'a ulasabildim ve basarili cevap aldim.

Bu calisma ile container ve host'un farkli network ortamlari oldugunu, bir servisin belirli bir portu dinleyebildigini ve Docker port mapping ile container'daki bir servisin host uzerinden erisilebilir hale getirilebildigini gordum.
