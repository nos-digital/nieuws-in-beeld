//
//  ImageLoading.swift
//  NOSNieuwsInBeeld
//
//  Created by Alvin Nutbeij on 03/07/2020.
//  Copyright © 2020 App Department. All rights reserved.
//

import AppKit


protocol ImageLoading
{
    func loadImage(from url: URL, completion: @escaping (Result<NSImage, Error>) -> Void)
}
