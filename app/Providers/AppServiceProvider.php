<?php

namespace App\Providers;

use App\Models\Config;
use App\Models\Process\Parameter\Database;
use FeWeDev\Base\Variables;
use Illuminate\Support\ServiceProvider;
use LaravelZero\Framework\Application;

/**
 * @author      Andreas Knollmann
 * @copyright   2014-2026 Softwareentwicklung Andreas Knollmann
 * @license     http://www.opensource.org/licenses/mit-license.php MIT
 */
class AppServiceProvider extends ServiceProvider
{
    public function boot(): void {}

    public function register(): void
    {
        $this->app->singleton(
            'process.parameters.database',
            function (Application $app) {
                return new Database(
                    $app->make(Variables::class),
                    $app->make(Config::class)
                );
            }
        );
    }
}
