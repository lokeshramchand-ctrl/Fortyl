package com.aegis.auth.controller;

import com.aegis.auth.dto.MfaConfirmRequest;
import com.aegis.auth.dto.MfaEnrollResponse;
import com.aegis.auth.service.MfaService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/mfa")
public class MfaController {

    private final MfaService service;

    public MfaController(MfaService service) {
        this.service = service;
    }

    @PostMapping("/enroll")
    public MfaEnrollResponse enroll(@RequestHeader("X-User-Id") String userId) {
        return service.enroll(userId);
    }

    @PostMapping(value = "/confirm", consumes = "application/json")
    public String confirm(@RequestBody MfaConfirmRequest request) {
        System.out.println("Confirm request: " + request);
        service.confirm(request.userId(), request.code());
        return "MFA confirmed";
    }

    @PostMapping("/verify")
    public String verify(@RequestBody MfaConfirmRequest request) {
        service.verify(request.userId(), request.code());
        return "MFA verified";
    }

}
