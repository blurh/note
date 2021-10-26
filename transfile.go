package main

/*
    背景: 
    机器使用堡垒机, 无法直接文件的上传下载(sftp, rz/sz 也不行
    且只放通了 80 443 两个端口
    所以用该工具临时监听 80/443 用于临时的文件传输
*/

import (
    "os"
    "fmt"
    "flag"
    "strings"
    "github.com/gin-gonic/gin"
)

var port string
const uploadPath string = "./upload/"
const downloadPath string = "./download/"

func Authorize() gin.HandlerFunc{
    return func(c *gin.Context){
        if token := c.GetHeader("token"); token == "QAZ12345" {
            c.Next()
        } else {
            c.Abort()
            c.JSON(401, gin.H{"error": "token unknow!"})
            return
        }
    }
}

func main() {
    flag.StringVar(&port, "p", "5050", "run port")
    flag.Parse()
    gin.SetMode(gin.ReleaseMode)
    r := gin.Default()
    r.Use(Authorize())
    r.MaxMultipartMemory = 1 << 20
    r.POST("/uploadfile", func(c *gin.Context) {
        file, err := c.FormFile("file");
        if err != nil {
            c.JSON(500, gin.H{"msg": "get file name fail: " + err.Error()})
            c.Abort()
            return
        }
        pathFileSlice := strings.Split(file.Filename, "/")
        filename := pathFileSlice[len(pathFileSlice) - 1]
        if _, err := os.Stat(uploadPath); err != nil {
            fmt.Println(uploadPath, "upload path not exist, create now")
            os.Mkdir(uploadPath, 0644)
        }
        if err := c.SaveUploadedFile(file, uploadPath + filename); err != nil {
            c.JSON(500, gin.H{"msg": err.Error()})
            c.Abort()
            return
        }

        c.JSON(200, gin.H{"msg": file.Filename + " upload success"})
    })
    r.GET("/downloadfile/:filename", func(c *gin.Context) {
        filepath := downloadPath
        filename := c.Param("filename")
        c.Writer.Header().Add("Content-Disposition", "attachment; filename=" + filename)
        c.Writer.Header().Add("Content-Type", "application/octet-stream")
        c.File(filepath + filename)
    })
    fmt.Printf("Now listen port is: %s, use `-p` to change this listen port\n", port)
    fmt.Printf("Usage: `wget --header=\"token:xx\" localhost:%s/downloadfile/<filename>` to download file\n", port)
    fmt.Printf("Usage: `curl -H \"token:xx\" -X POST http://<host>:%s/uploadfile -F \"file=@<filename>\"` to uploadload file\n", port)
    r.Run(":" + port)
}

