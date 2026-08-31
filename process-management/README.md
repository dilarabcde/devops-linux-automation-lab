# Process Management

Bu çalışmada Linux'ta process ve PID kavramlarını Docker üzerinde Ubuntu kullanarak uygulamalı olarak inceledim.

## Process ve PID

Çalışmakta olan bir program bir process olarak çalışır. Her process'in işletim sistemi tarafından verilen bir PID (Process ID) değeri vardır.

Çalışan process'leri görmek için:

```bash
ps aux
```

komutunu kullandım.

Yeni bir process oluşturmak için:

```bash
sleep 300 &
```

komutunu çalıştırdım. Buradaki `&` sayesinde process arka planda çalışmaya devam etti.

Daha sonra tekrar:

```bash
ps aux
```

komutunu kullanarak oluşturduğum `sleep` process'ini ve PID değerini gördüm.

Bir process'i PID üzerinden sonlandırmak için:

```bash
kill <PID>
```

komutunu kullandım.

## Container ve PID 1

Ubuntu container'ını:

```bash
docker run -it ubuntu bash
```

komutuyla başlattım.

Container `bash` ile başlatıldığı için `bash`, container içerisindeki ana process oldu ve PID 1 değerini aldı.

Burada container'ın yaşam döngüsünün ana process ile bağlantılı olduğunu gördüm. PID 1 sonlandığında container durur ancak otomatik olarak silinmez.

Bu çalışma sonunda process, PID, arka planda process çalıştırma, çalışan process'leri görüntüleme ve process sonlandırma işlemlerini uygulamalı olarak öğrenmiş oldum.
