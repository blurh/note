package main

import (
    "encoding/json"
    "fmt"
    "time"

    "github.com/gin-gonic/gin"

    admissionv1 "k8s.io/api/admission/v1"
    corev1 "k8s.io/api/core/v1"
    metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

const timeFormat = "2006-01-02 15:04:05"

type patchOperation struct {
    OP    string          `json:"op"`
    Path  string          `json:"path"`
    Value json.RawMessage `json:"value,omitempty"`
}

func main() {
    gin.SetMode(gin.ReleaseMode)
    r := gin.Default()
    r.GET("/ping", func(c *gin.Context) {
        c.JSON(200, gin.H{"message": "pong"})
    })
    r.POST("/mutating", HandleMutate)
    err := r.RunTLS(":443", "tls/tls.crt", "tls/tls.key")
    if err != nil {
        fmt.Println("gin start fail:", err.Error())
    }
}

func HandleMutate(c *gin.Context) {
    admissionReview := &admissionv1.AdmissionReview{}
    json.NewDecoder(c.Request.Body).Decode(admissionReview)

    var pod corev1.Pod
    json.Unmarshal(admissionReview.Request.Object.Raw, &pod)

    nowTime := time.Now().Format(timeFormat)
    commandArg := "this init container injected right now: " + nowTime

    container := []corev1.Container{{
        Name:            "inject-init-container",
        Image:           "busybox:latest",
        ImagePullPolicy: "IfNotPresent",
        Command:         []string{"printf", commandArg},
    }}
    pod.Spec.InitContainers = append(pod.Spec.InitContainers, container...)
    initContainersBytes, _ := json.Marshal(&pod.Spec.InitContainers)

    env := []corev1.EnvVar{{
        Name: "injected", Value: "ok",
    }}
    for i := 0; i <= len(pod.Spec.Containers)-1; i++ {
        pod.Spec.Containers[i].Env = append(pod.Spec.Containers[i].Env, env...)
    }
    containersBytes, _ := json.Marshal(&pod.Spec.Containers)

    patchLabel := patchOperation{
        OP:    "add",
        Path:  "/metadata/labels/injected",
        Value: []byte(`"ok"`),
    }
    patchInitContainer := patchOperation{
        OP:    "replace",
        Path:  "/spec/initContainers",
        Value: initContainersBytes,
    }
    patchContainer := patchOperation{
        OP:    "replace",
        Path:  "/spec/containers",
        Value: containersBytes,
    }
    patch := []patchOperation{patchLabel, patchInitContainer, patchContainer}
    patchBytes, _ := json.Marshal(&patch)

    patchType := admissionv1.PatchTypeJSONPatch

    admissionResponse := &admissionv1.AdmissionResponse{
        UID:       admissionReview.Request.UID,
        Allowed:   true,
        Patch:     patchBytes,
        PatchType: &patchType,
    }

    respAdmissionReview := &admissionv1.AdmissionReview{
        TypeMeta: metav1.TypeMeta{
            Kind:       "AdmissionReview",
            APIVersion: "admission.k8s.io/v1",
        },
        Response: admissionResponse,
    }

    c.JSON(200, &respAdmissionReview)
    return
}
