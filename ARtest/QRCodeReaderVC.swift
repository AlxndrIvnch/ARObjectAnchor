//
//  QRCodeReaderVC.swift
//  ARtest
//
//  Created by alexander.ivanchenko on 23.02.2023.
//

import UIKit
import MercariQRScanner
import AVFoundation

class QRCodeReaderVC: UIViewController {
    let loader = UIActivityIndicatorView(style: .large)
    var qrScannerView: QRScannerView!
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask { .portrait }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupQRScanner()
        setupLoader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        qrScannerView.rescan()
        qrScannerView.startRunning()
    }

    private func setupQRScanner() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupQRScannerView()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async { [weak self] in
                        self?.setupQRScannerView()
                    }
                }
            }
        default:
            showAlert()
        }
    }

    private func setupQRScannerView() {
        qrScannerView = QRScannerView(frame: view.bounds)
        view.addSubview(qrScannerView)
        qrScannerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([qrScannerView.topAnchor.constraint(equalTo: self.view.topAnchor),
                                     qrScannerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                                     qrScannerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                     qrScannerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)])
        
//        qrScannerView.focusImage = UIImage(named: "scan_qr_focus")
//        qrScannerView.focusImagePadding = 8.0
//        qrScannerView.animationDuration = 0.5
        
        qrScannerView.configure(delegate: self)
    }
    
    private func setupLoader() {
        qrScannerView.addSubview(loader)
        loader.center = qrScannerView.center
//        loader.autoresizingMask = [.]
        loader.hidesWhenStopped = true
        loader.color = .systemIndigo
        loader.stopAnimating()
    }

    private func showAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            let alert = UIAlertController(title: "Error", message: "Camera is required to use in this application", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
    
    private func loadImage(from url: URL, completion: @escaping (UIImage) -> Void) {
        DispatchQueue.global().async {
            let data = try! Data(contentsOf: url)
            let image = UIImage(data: data)!
            completion(image)
        }
    }
    
    private func showAR(with image: UIImage) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let arVC = storyboard.instantiateViewController(withIdentifier: "ARVC") as? ARVC else { return }
        arVC.modalPresentationStyle = .fullScreen
//        arVC.image = image
        self.present(arVC, animated: true)
    }
}

extension QRCodeReaderVC: QRScannerViewDelegate {
    func qrScannerView(_ qrScannerView: QRScannerView, didFailure error: QRScannerError) {
        print(error)
    }

    func qrScannerView(_ qrScannerView: QRScannerView, didSuccess code: String) {
        let url = URL(string: code)!
        loader.startAnimating()
        qrScannerView.bringSubviewToFront(loader)
        loadImage(from: url) { [weak self] image in
            DispatchQueue.main.async {
                self?.showAR(with: image)
                self?.loader.stopAnimating()
                self?.qrScannerView.stopRunning()
            }
        }
    }
}
