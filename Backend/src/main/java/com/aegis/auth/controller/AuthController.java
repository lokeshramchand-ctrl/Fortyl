import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.aegis.auth.repository.UserRepository;
import com.aegis.auth.dto.AuthResponse;
import com.aegis.auth.dto.LoginRequest;
import com.aegis.auth.entity.AuthService;

@RestController
@RequestMapping("/auth")
public class AuthController {

  private final AuthService authService;

  public AuthController(AuthService authService) {
    this.authService = authService;
  }

  @PostMapping("/login")
  public AuthResponse login(@RequestBody LoginRequest req) {
    return authService.login(req.email(), req.password());
  }
}
