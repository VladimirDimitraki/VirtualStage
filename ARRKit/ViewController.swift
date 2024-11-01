//
//  ViewController.swift
//  ARRKit
//
//  Created by Melania Dababi on 11/1/24.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {
    
    //Отображает сцену дополненной реальности
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //1. Обнаружение плоскости
        startPlaneDetection()
        
        // Получить доступ к плоскости и разместить виртуальный объект в порежеленной точке
        
        //2. Получаем точку
        arView.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        //Получаем координаты касания
        let tapLocation = recognizer.location(in: arView)
        
        /*Взять точки и преобразовать их в реальные координаты втрехмерном пространстве Запустим луч (луч исходит из камеры и падает на плоскость) в результате имее конкретную точку в пространстве (2D -> 3D)
         */
        
        /*
         allowing (ARRaycastQuery.Target):
         
        Определяет, какие объекты будут попадать под трассировку луча. Возможные значения:
         
        .existingPlane: Луч будет взаимодействовать только с существующими плоскостями (например, плоскости, определенные ARKit).
         
        .existingPlaneUsingExtent: Это значение также будет рассматривать существующие плоскости, но с учетом их размеров.
         
        .estimatedPlane: Позволяет взаимодействовать с предполагаемыми
          плоскостями, которые могут быть обнаружены ARKit, но еще не были подтверждены.
         
        .featurePoint: Позволяет трассировать лучи по точкам, обнаруженным ARKit, которые представляют интересные характеристики окружения.
         
         alignment (ARRaycastQuery.TargetAlignment):

         Определяет ориентацию плоскости, с которой будет взаимодействовать луч. Возможные значения:
         .horizontal: Луч будет направлен на взаимодействие с горизонтальными плоскостями (например, полы).
         .vertical: Луч будет направлен на взаимодействие с вертикальными плоскостями (например, стены).
         */
        let result = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
        
        //Если есть результат то получим доступ к первой плоскости
        if let firstResult = result.first {
            //Получаем трехмерную точку касания исохраняем в переменную (x,y,z)
            let position = simd_make_float3(firstResult.worldTransform.columns.3)
            //Создаем сферу
            let sphere = create3DObjectSphere()
            //Размещаем сферу
            placementObject(object: sphere, at: position)
        }
    }
    
    func startPlaneDetection() {
        //Конфигурация для определени я плоскости
        arView.automaticallyConfigureSession = true
        
        //Переменная для отслеживания конфигурации
        let configuration = ARWorldTrackingConfiguration()
        
        //Функция определения плоскости
        configuration.planeDetection = [.horizontal]
        
        //Автоматическое текестурирование местности (повышает реалистичность и рэндеринг)
        configuration.environmentTexturing = .automatic
        
        //Запускаем сессию Ar для обнаружения горизонтальной плоскости
        arView.session.run(configuration)
    }
    
    func create3DObjectSphere() -> ModelEntity {
        
        //Сетка
        let sphere = MeshResource.generateSphere(radius: 0.05)
        
        //Присваеваем материал
        let sphereMaterial = SimpleMaterial(color: .blue, roughness: 0, isMetallic: true)
        
        //Модель
        let sphereEntity = ModelEntity(mesh: sphere, materials: [sphereMaterial])
        return sphereEntity
    }
    
    
    //Размещение объекта
    func placementObject(object: ModelEntity, at location: SIMD3<Float>) {
        //Создаем (Якорь - крючки которые фиксируют реальный обьект в 3D пространстве)
        let objectAnchor = AnchorEntity(world: location)
        
        //2.Размещаем модел на точке (якоре)
        objectAnchor.addChild(object)
        
        //3.Добавляем точку (якорь) на сцену
        arView.scene.addAnchor(objectAnchor)
    }
}
